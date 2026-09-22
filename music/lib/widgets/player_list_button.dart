import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/player_controller.dart';
import 'package:provider/provider.dart';

/// 歌曲列表按钮及悬浮窗显示组件
class PlayerListButton extends StatefulWidget {
  const PlayerListButton({super.key});

  @override
  State<PlayerListButton> createState() => _PlayerListButtonState();
}

class _PlayerListButtonState extends State<PlayerListButton> {

  final FlyoutController _playlistFlyoutController = FlyoutController();

  // controller回收
  @override
  void dispose() {
    _playlistFlyoutController.dispose();
    super.dispose();
  }

  // 歌曲列表悬浮卡片弹出
  void _showPlaylistFlyout() {
    _playlistFlyoutController.showFlyout(
      placementMode: FlyoutPlacementMode.topRight,
      builder: (context) {
        return FlyoutContent(
          child: SizedBox(
            width: 533,
            height: 300,
            child: Consumer<PlayerController>(
              builder: (context, player, child) {
                if(player.playlist.isEmpty) { 
                  return const Center(child: Text("播放列表为空", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    const Padding(padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0), child: Text('播放列表', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'NotoSansCJKsc'))),
                    // 分割线
                    const Padding(padding: EdgeInsets.only(bottom: 6.0), child: Divider()),
                    // 歌曲列表
                    Expanded(
                      child: ListView.builder(
                        itemCount: player.playlist.length,
                        itemBuilder: (context, index) {
                          final song = player.playlist[index];
                          final isCurrent = index == player.currentIndex;
                          return ListTile(
                            title: Text(
                              song.displayTitle,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc', color: isCurrent ? Colors.blue : null),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist ?? "未知艺术家",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc', color: isCurrent ? Colors.blue : null),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () {
                              player.playSong(player.playlist, index);
                            },
                          );
                        }
                      )
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: _playlistFlyoutController,
      child: SizedBox(
        height: 40.0,
        width: 40.0,
        child: IconButton(
          icon: const Icon(WindowsIcons.music_info),
          onPressed: _showPlaylistFlyout,
        ),
      ),
    );
  }
}