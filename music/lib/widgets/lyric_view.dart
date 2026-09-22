import 'package:fluent_ui/fluent_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../utils/lyric_parser.dart';

/// 歌词显示组件
class LyricView extends StatefulWidget {
  final List<LyricLine> lines;
  final int currentIndex;
  final TextAlign textAlign;
  final ValueChanged<LyricLine>? onLineTap;
  final double fontSize;
  final FontWeight fontWeight;

  const LyricView({
    super.key,
    required this.lines,
    required this.currentIndex,
    required this.textAlign,
    this.onLineTap,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  State<LyricView> createState() => _LyricViewState();
}

class _LyricViewState extends State<LyricView> {
  final ItemScrollController _scrollController = ItemScrollController();
  // 上下各加一个占位项，让第一行和最后一行也能滚到中间
  static const int _padCount = 1;

  @override
  void initState() {
    super.initState();
    // 首次进来也滚动一次
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void didUpdateWidget(covariant LyricView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    if (widget.currentIndex < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.isAttached) return;
      _scrollController.scrollTo(
        index: widget.currentIndex + _padCount,
        alignment: 0.5, // 0.5 = 垂直居中
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ---- 主题感知颜色 ----
    final highlightColor = isDark ? Colors.white : Colors.black;
    final normalColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1);

    if (widget.lines.isEmpty) { return const Center(child: Text('暂无歌词', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))); }

    return ScrollablePositionedList.builder(
      itemScrollController: _scrollController,
      itemCount: widget.lines.length + _padCount * 2,
      itemBuilder: (context, index) {
        // 上下占位
        if (index < _padCount || index >= widget.lines.length + _padCount) {
          return const SizedBox(height: 200);
        }

        final lineIndex = index - _padCount;
        final line = widget.lines[lineIndex];
        final isCurrent = lineIndex == widget.currentIndex;

        return GestureDetector(
          onTap: () => widget.onLineTap?.call(line),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 主歌词
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(fontSize: widget.fontSize, fontWeight: widget.fontWeight, color: isCurrent ? highlightColor : normalColor, fontFamily: 'NotoSansCJKsc'),
                  child: Text(line.text, textAlign: widget.textAlign),
                ),
                // 翻译（同时间轴，同时高亮）
                if (line.translation != null && line.translation!.isNotEmpty) 
                  ...[
                  const SizedBox(height: 2.0),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(fontSize: widget.fontSize, fontWeight: widget.fontWeight, color: isCurrent ? highlightColor : normalColor, fontFamily: 'NotoSansCJKsc'),
                    child: Text(line.translation!, textAlign: widget.textAlign),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}