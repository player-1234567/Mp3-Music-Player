import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/player_controller.dart';
import 'package:music/models/song_model.dart';
import 'package:provider/provider.dart';

/// 通用卡片: 各页面歌曲卡片
class SongCard extends StatelessWidget {
  final SongModel song;
  final List<SongModel> songs;
  final int index;
  const SongCard({super.key, required this.song, required this.songs, required this.index});

  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select<PlayerController, bool>((c) => c.currentSong?.id == song.id && c.isPlaying);
    return GestureDetector(
      onTap: () => context.read<PlayerController>().playSong(songs, index),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26.0, 8.0, 26.0, 0.0),
        child: Card(
          padding: EdgeInsetsGeometry.zero,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                // 内嵌封面
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    color: Colors.grey,
                    child: song.coverArt != null 
                      ? Image.memory(
                          song.coverArt!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          cacheWidth: 120,
                          gaplessPlayback: true,
                        ) 
                      : const Icon(FluentIcons.music_note, size: 30),
                  ),
                ),
                const SizedBox(width: 10),
                // 歌曲名, 艺术家
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.displayTitle,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSansCJKsc',
                          color: isPlaying ? Colors.blue : null,
                        ), 
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        song.artist ?? "未知艺术家",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSansCJKsc',
                          color: isPlaying ? Colors.blue : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // 歌曲副标题
                Expanded(
                  flex: 3,
                  child: Text(
                    song.subtitle ?? "",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'NotoSansCJKsc',
                    ),
                    overflow: TextOverflow.ellipsis),
                ),
                // 歌曲时长
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: Text(
                    song.durationText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'NotoSansCJKsc',
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
