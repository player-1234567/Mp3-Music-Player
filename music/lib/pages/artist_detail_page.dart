import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/library_controller.dart';
import 'package:music/models/song_model.dart';
import 'package:music/widgets/song_card.dart';
import 'package:provider/provider.dart';

class ArtistDetailPage extends StatelessWidget {
  final String artistName;
  const ArtistDetailPage({super.key, required this.artistName});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, controller, child) {
        // 获取歌手的歌曲列表
        final artistMap = controller.getSongsGroupedByArtist();
        final artistSongs = artistMap[artistName] ?? [];

        return ScaffoldPage(
          header: PageHeader(
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(26.0, 0.0, 14.0, 0.0),
              child: SizedBox(
                height: 40,
                width: 40,
                child: IconButton(icon: Icon(WindowsIcons.back, fontWeight: FontWeight.w900,), onPressed: () => Navigator.pop(context))
              ),
            ),
            title: Text(artistName, style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'NotoSansCJKsc'), overflow: TextOverflow.ellipsis),
            commandBar: Text("共${artistSongs.length}首歌曲", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
          ),
          content: SizedBox.expand(child: _artistSongsContent(artistSongs: artistSongs)),
        );
      }
    );
  }

  Widget _artistSongsContent({required List<SongModel> artistSongs}) {
    if(artistSongs.isEmpty) {
      return Center(child: Text("该艺术家暂无歌曲", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }
    return ListView.builder(
      itemCount: artistSongs.isEmpty ? 0 : artistSongs.length + 1,
      itemBuilder: (context, index) {
        if (artistSongs.isEmpty) return const SizedBox.shrink();
        if (index == artistSongs.length) {
          return const SizedBox(height: 100.0);
        }
        final song = artistSongs[index];
        return SongCard(song: song, songs: artistSongs, index: index);
      },
    );
  }
}