import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/library_controller.dart';
import 'package:music/pages/album_detail_page.dart';
import 'package:provider/provider.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, controller, child) {
        // 获取专辑分组数据
        final albumMap = controller.getSongsGroupedByAlbum();
        final albumNames = albumMap.keys.toList();
        // 专辑排序
        albumNames.sort((a, b) => a.compareTo(b));
        return ScaffoldPage(
          header: PageHeader(title: Text("专辑", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'NotoSansCJKsc'))),
          content: SizedBox.expand(child: _albumsContent(albumNames: albumNames)),
        );
      },
    );
  }

  // [专辑页面]专辑卡片组件
  Widget _albumCard({required String album, required VoidCallback onTap}) {
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
              child: Text(album, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            )
          ),
        ),
      ),
    );
  }

  // [专辑页面]专辑列表
  Widget _albumsContent({required List albumNames}) {
    if(albumNames.isEmpty) {
      return Center(child: Text("暂无专辑", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }
    return ListView.builder(
      itemCount: albumNames.isEmpty ? 0 : albumNames.length + 1,
      itemBuilder: (context, index) {
        if (albumNames.isEmpty) return const SizedBox.shrink();
        if (index == albumNames.length) {
          return const SizedBox(height: 100.0);
        }
        final albumName = albumNames[index];
        return _albumCard(
          album: albumName, 
          onTap: () {
            Navigator.push(context, FluentPageRoute(builder: ((context) => AlbumDetailPage(albumName: albumName))));
          },
        );
      },
    );
  }
}
