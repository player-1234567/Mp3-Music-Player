import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/widgets/player_controls.dart';
import 'package:music/widgets/player_hotkeys.dart';
import 'package:music/widgets/player_list_button.dart';
import 'package:music/widgets/player_time_text.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:music/controllers/player_controller.dart';
import 'package:music/pages/album_page.dart';
import 'package:music/pages/artist_page.dart';
import 'package:music/pages/music_page.dart';
import 'package:music/pages/player_page.dart';
import 'package:music/pages/setting_page.dart';
import 'package:music/widgets/caption_buttons.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectIndex = 0;
  final GlobalKey<NavigatorState> _albumNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _artistNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _musicNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PlayerHotkeys(
      child: Stack(
        children: [
          // fluent骨架
          NavigationView(
            titleBar: SizedBox(
              height: 40,
              child: Row(
                children: [
                  const SizedBox(width: 16.0),
                  // 软件标题名
                  const Text("Mp3 Music Player", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'NotoSansCJKsc')),
                  // 中间空白可移动区域
                  const Expanded(child: DragToMoveArea(child: SizedBox.expand())),
                  // 最大化, 最小化, 关闭按钮
                  CaptionButtons(),
                ],
              ),
            ),
            pane: NavigationPane(
              size: const NavigationPaneSize(openMaxWidth: 160),
              displayMode: PaneDisplayMode.compact,
              toggleButtonPosition: PaneToggleButtonPreferredPosition.pane,
              toggleButton: SizedBox(height: 40, child: PaneToggleButton()),
              selected: _selectIndex,
              onChanged: (index) => setState(() => _selectIndex = index),
              items: [
                PaneItem(
                  icon: const SizedBox(height: 40, child: Icon(WindowsIcons.music_note)),
                  title: Text("本地音乐", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                  body: _buildNestedNavigator(key: _musicNavigatorKey, child: const MusicPage()),
                ),
                PaneItem(
                  icon: const SizedBox(height: 40, child: Icon(WindowsIcons.music_album)),
                  title: Text("专辑", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                  body: _buildNestedNavigator(key: _albumNavigatorKey, child: const AlbumPage()),
                ),
                PaneItem(
                  icon: const SizedBox(height: 40, child: Icon(WindowsIcons.people)),
                  title: Text("艺术家", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                  body: _buildNestedNavigator(key: _artistNavigatorKey, child: const ArtistPage()),
                ),
              ],
              footerItems: [
                PaneItem(
                  icon: const SizedBox(height: 40, child: Icon(WindowsIcons.settings)),
                  title: Text("设置", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                  body: SettingPage(),
                ),
              ]
            ),
          ),
          // 播放栏
          _musicPlayerBar(),
        ],
      ),
    );
  }

  // 控制页面的子页面正常跳转
  Widget _buildNestedNavigator({required GlobalKey<NavigatorState> key, required Widget child}) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) => FluentPageRoute(builder: (context) => child),
    );
  }

  // [主页面]音乐播放栏
  Widget _musicPlayerBar() {
    return Consumer<PlayerController>(
      builder: (context, player, child) {
        final song = player.currentSong;
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          left: 180,
          bottom: 20,
          right: 140,
          child: Card(
            padding: EdgeInsetsGeometry.zero,
            child: SizedBox(
              height: 60.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 内嵌封面, 歌曲名, 艺术家
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                            image: null,
                          ),
                          child: song?.coverArt != null 
                                 ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.memory(song!.coverArt!, width: 60, height: 60, fit: BoxFit.cover),
                                 )
                                 : const Icon(FluentIcons.music_note, size: 30),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song?.displayTitle ?? "未播放",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NotoSansCJKsc',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                song?.artist ?? "-",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'NotoSansCJKsc',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  // 上一首按钮, 暂停/播放按钮, 下一首按钮
                  Expanded(flex: 1, child: PlayerControls()),
                  // 音乐播放时长/总时长显示, 播放列表按钮
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // 播放时长, 总时长
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: SizedBox(
                            height: 40.0,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                child: PlayerTimeText(),
                              ),
                            ),
                          ),
                        ),
                        // 播放列表按钮
                        Padding(padding: const EdgeInsets.only(right: 4.0), child: PlayerListButton()),
                        // 全屏音乐按钮
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: IconButton(
                              icon: const Icon(WindowsIcons.full_screen),
                              onPressed: () => Navigator.of(context, rootNavigator: true).push(FluentPageRoute(builder: (context) => const PlayerPage())),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}