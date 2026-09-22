import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/player_controller.dart';
import 'package:music/controllers/setting_controller.dart';
import 'package:music/utils/lyric_parser.dart';
import 'package:music/widgets/caption_buttons.dart';
import 'package:music/widgets/lyric_view.dart';
import 'package:music/widgets/player_controls.dart';
import 'package:music/widgets/player_hotkeys.dart';
import 'package:music/widgets/player_list_button.dart';
import 'package:music/widgets/player_time_text.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {

  // 进度条拖动状态
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return PlayerHotkeys(
      child: ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Column(
          children: [
            _buildTopBar(),
            Expanded(child: Consumer<PlayerController>(builder: (context, player, _) => _buildContent(player))),
            Consumer<PlayerController>(builder: (context, player, _) => _buildBottomBar(player)),
          ],
        ),
      ),
    );
  }

  // [音乐播放页面]顶部栏
  Widget _buildTopBar() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          // 返回按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: SizedBox(
              height: 40,
              width: 40,
              child: IconButton(
                icon: const Icon(WindowsIcons.back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // 中间空白可拖动区域
          const Expanded(child: DragToMoveArea(child: SizedBox.expand())),
          // 最小化
          CaptionButtons(),
        ],
      ),
    );
  }

  // [音乐播放页面]内容栏
  Widget _buildContent(PlayerController player) {
    final song = player.currentSong;
    if (song == null) { return const Center(child: Text('未在播放', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))); }
    // 封面模式
    if (player.showCover) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth * 0.2;
                final verticalPadding = constraints.maxHeight * 0.08;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, 6.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: song.coverArt != null ? Image.memory(song.coverArt!, fit: BoxFit.cover) : Container(color: Colors.grey, child: const Center(child: Icon(WindowsIcons.music_note, size: 40.0)),),
                        )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 0.0, horizontalPadding, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.displayTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'NotoSansCJKsc'), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2.0),
                          Text(song.artist ?? "未知艺术家", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2.0),
                          Text(song.subtitle ?? "", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // ---- 右侧：歌词 ----
          Expanded(
            flex: 1,
            child: _buildLyricArea(player),
          ),
        ],
      );
    }

    // 歌词模式
    return _buildLyricArea(player);
  }

  // [音乐播放页面]内容栏歌词区域组件
  Widget _buildLyricArea(PlayerController player) {
    final song = player.currentSong;
    if (song == null || song.lyric == null || song.lyric!.isEmpty) {
      return const Center(child: Text('暂无歌词', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }
    // 只解析一次，别放在 build 里每次解析
    final lines = player.lyricLines;

    final currentIndex = LyricParser.indexAt(lines, player.position);
    final textAlign = switch (player.lyricAlign) { 0 => TextAlign.left, 2 => TextAlign.right, _ => TextAlign.center };
    final settings = context.watch<SettingController>();
  
    return LyricView(
      lines: lines,
      currentIndex: currentIndex,
      textAlign: textAlign,
      onLineTap: (line) => player.seekTo(line.time),
      fontSize: settings.fontSize.toDouble(),
      fontWeight: _intToFontWeight(settings.fontWeight),
    );
  }

  FontWeight _intToFontWeight(int value) {
    switch (value) {
      case 100: return FontWeight.w100;
      case 200: return FontWeight.w200;
      case 300: return FontWeight.w300;
      case 400: return FontWeight.w400;
      case 500: return FontWeight.w500;
      case 600: return FontWeight.w600;
      case 700: return FontWeight.w700;
      case 800: return FontWeight.w800;
      case 900: return FontWeight.w900;
      default:  return FontWeight.w400;
    }
  }

  // [音乐播放页面]底部播放栏
  Widget _buildBottomBar(PlayerController player) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 音乐播放进度条
          SizedBox(
            height: 20.0,
            child: Slider(
              value: _isDragging ? _dragValue : player.progress,
              max: 1.0,
              onChangeStart: (value) => setState(() => _isDragging = true),
              onChanged: (value) => setState(() => _dragValue = value),
              onChangeEnd: (value) {
                final target = Duration(milliseconds: (player.duration.inMilliseconds * value).round());
                player.seekTo(target);
                setState(() => _isDragging = false);
              },
            ),
          ),
          const SizedBox(height: 4.0),
          // 播放栏
          Row(
            children: [
              const SizedBox(width: 10.0),
              // 播放时长, 音乐时长显示
              Expanded(flex: 1, child: PlayerTimeText()),
              // 上一首按钮, 播放/暂停按钮, 下一首按钮
              Expanded(flex: 1, child: PlayerControls()),
              // 右侧：歌词位置 / 播放列表 / 内容栏切换
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 封面, 歌词类型切换
                    Container(
                      decoration: BoxDecoration(color: const Color.fromARGB(30, 68, 68, 68), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 封面切换
                          GestureDetector(
                            onTap: () => player.toggleShowCover(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: player.showCover ? const Color.fromARGB(200, 0, 174, 255) : Colors.transparent, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                "封面",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NotoSansCJKsc',
                                  color: player.showCover ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          // 歌词切换
                          GestureDetector(
                            onTap: () => player.toggleShowCover(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: !player.showCover ? const Color.fromARGB(200, 0, 174, 255) : Colors.transparent, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                "歌词",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NotoSansCJKsc',
                                  color: player.showCover ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    // 歌词位置切换（左对齐/居中/右对齐）
                    SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: IconButton(
                        icon: Icon(player.lyricAlign == 0 ? WindowsIcons.align_left : player.lyricAlign == 2 ? WindowsIcons.align_right : WindowsIcons.align_center, size: 16),
                        onPressed: () => player.cycleLyricAlign(),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    // 播放列表
                    PlayerListButton(),
                    const SizedBox(width: 10.0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
