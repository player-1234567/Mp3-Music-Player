import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

/// 顶部按钮组件: 最小化, 最大化(还原), 关闭按钮 [已完成]
class CaptionButtons extends StatefulWidget {
  const CaptionButtons({super.key});

  @override
  State<CaptionButtons> createState() => _CaptionButtonsState();
}

class _CaptionButtonsState extends State<CaptionButtons> with WindowListener {

  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _updateMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _updateMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    if (mounted && _isMaximized != isMaximized) {
      setState(() => _isMaximized = isMaximized);
    }
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  void _restoreMaximizeChange() {
    if (_isMaximized) {
      windowManager.unmaximize();
    } else {
      windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 40.0,
          width: 40.0,
          child: IconButton(
            icon: const Icon(WindowsIcons.chrome_minimize, size: 12),
            onPressed: () => windowManager.minimize(),
          ),
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: IconButton(
            icon: Icon(_isMaximized ? WindowsIcons.chrome_restore : WindowsIcons.chrome_maximize, size: 12),
            onPressed: () => _restoreMaximizeChange(),
          ),
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: IconButton(
            icon: const Icon(WindowsIcons.chrome_close, size: 12),
            style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) => states.contains(WidgetState.hovered) ? Colors.red : Colors.transparent)),
            onPressed: () => windowManager.close(),
          ),
        ),
      ],
    );
  }
}