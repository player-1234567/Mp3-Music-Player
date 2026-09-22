import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/library_controller.dart';
import 'package:music/models/song_model.dart';
import 'package:music/widgets/song_card.dart';
import 'package:provider/provider.dart';

class AlbumDetailPage extends StatelessWidget {
  final String albumName;
  const AlbumDetailPage({super.key, required this.albumName});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, controller, child) {
        // 获取该专辑的歌曲列表
        final albumMap = controller.getSongsGroupedByAlbum();
        final albumSongs = albumMap[albumName] ?? [];

        // 按音轨号排序（升序）
        final sortedSongs = List<SongModel>.from(albumSongs)..sort((a, b) {
          final aTrack = a.trackNumber ?? 9999;
          final bTrack = b.trackNumber ?? 9999;
          return aTrack.compareTo(bTrack);
        });

        return ScaffoldPage(
          header: PageHeader(
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(26.0, 0.0, 14.0, 0.0),
              child: SizedBox(
                height: 40,
                width: 40,
                child: IconButton(icon: Icon(WindowsIcons.back, fontWeight: FontWeight.w900), onPressed: () => Navigator.pop(context))
              ),
            ),
            title: Text(albumName, style: TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            commandBar: Text("共${sortedSongs.length}首歌曲", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
          ),
          content: SizedBox.expand(child: _albumSongsContent(sortedSongs: sortedSongs)),
        );
      }
    );
  }

  Widget _albumSongsContent({required List<SongModel> sortedSongs}) {
    if(sortedSongs.isEmpty) {
      return Center(child: Text("该专辑暂无歌曲", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }
    return ListView.builder(
      itemCount: sortedSongs.isEmpty ? 0 : sortedSongs.length + 1,
      itemBuilder: (context, index) {
        if (sortedSongs.isEmpty) return const SizedBox.shrink();
        if (index == sortedSongs.length) {
          return const SizedBox(height: 100.0);
        }
        final song = sortedSongs[index];
        return SongCard(song: song, songs: sortedSongs, index: index);
      },
    );
  }
}