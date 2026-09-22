import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/library_controller.dart';
import 'package:music/pages/artist_detail_page.dart';
import 'package:provider/provider.dart';

class ArtistPage extends StatelessWidget {
  const ArtistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, controller, child) {
        // 获取艺术家分组数据
        final artistMap = controller.getSongsGroupedByArtist();
        final artistNames = artistMap.keys.toList();
        // 艺术家名称排序
        artistNames.sort((a, b) => a.compareTo(b));
        return ScaffoldPage(
          header: PageHeader(title: Text("艺术家", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'NotoSansCJKsc'))),
          content: SizedBox.expand(
            child: _artistsContent(artistNames: artistNames),
          ),
        );
      },
    );
  }

  // [艺术家页面]艺术家卡片组件
  Widget _artistCard({required String artist, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26.0, 8.0, 26.0, 0.0),
        child: Card(
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: 40, 
            child: Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(artist, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'), overflow: TextOverflow.ellipsis),
            )
          ),
        ),
      ),
    );
  }

  // [艺术家页面]艺术家列表
  Widget _artistsContent({required List artistNames}) {
    if(artistNames.isEmpty) {
      return Center(child: Text("暂无艺术家", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }
    return ListView.builder(
      itemCount: artistNames.isEmpty ? 0 : artistNames.length + 1,
      itemBuilder: (context, index) {
        if (artistNames.isEmpty) return const SizedBox.shrink();
        if (index == artistNames.length) {
          return const SizedBox(height: 100.0);
        }
        final artistName = artistNames[index];
        return _artistCard(
          artist: artistName, 
          onTap: () {
            Navigator.push(context, FluentPageRoute(builder: ((context) => ArtistDetailPage(artistName: artistName))));
          },
        );
      },
    );
  }
}