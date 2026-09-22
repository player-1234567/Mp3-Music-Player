import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/library_controller.dart';
import 'package:music/controllers/setting_controller.dart';
import 'package:music/models/song_model.dart';
import 'package:music/widgets/song_card.dart';
import 'package:provider/provider.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  // 排序类型, 排序顺序, 搜索关键词
  String _sortType = 'title'; // 'title' | 'subtitle' | 'album' | 'artist'
  String _sortOrder = 'asc'; // 'asc' | 'desc'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoLoadSongs());
  }

  void _autoLoadSongs() {
    final settings = context.read<SettingController>();
    final path = settings.musicFolderPath;
    if(path.isNotEmpty) {
      context.read<LibraryController>().loadSongs(path);
    }
  }

  // 获取排序后的歌曲列表 (先过滤再排序)
  List<SongModel> _getFilteredAndSortedSongs(List<SongModel> allSongs) {
    List<SongModel> songs = allSongs;
    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      songs = songs.where((song) {
        return song.displayTitle.toLowerCase().contains(query) || (song.artist!.toLowerCase().contains(query)) || (song.subtitle!.toLowerCase().contains(query)) || (song.album!.toLowerCase().contains(query));
      }).toList();
    }

    // 歌曲排序
    songs.sort((a, b) {
      int result;
      switch (_sortType) {
        case 'title':
          result = a.displayTitle.compareTo(b.displayTitle);
          break;
        case 'subtitle':
          final aSubtitle = a.subtitle ?? "";
          final bSubtitle = b.subtitle ?? "";
          result = aSubtitle.compareTo(bSubtitle);
          break;
        case 'album':
          final aAlbum = a.album ?? "";
          final bAlbum = b.album ?? "";
          result = aAlbum.compareTo(bAlbum);
          break;
        case 'artist':
          final aArtist = a.artist ?? "";
          final bArtist = b.artist ?? "";
          result = aArtist.compareTo(bArtist);
          break;
        default:
          result = 0;
      }
      return _sortOrder == "asc" ? result : -result;
    });
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, controller, child) {
        final displaySongs = _getFilteredAndSortedSongs(controller.allSongs);
        return ScaffoldPage(
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: const Text("本地音乐", style: TextStyle(fontWeight: FontWeight.w700)),
                commandBar: Text("共${controller.songCount}首歌曲", style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              _songsSortAndSearchBar(),
            ],
          ),
          content: SizedBox.expand(child: _songsContent(controller: controller, displaySongs: displaySongs)),
        );
      },
    );
  }

  // [音乐页面]排序及搜索组件
  Widget _songsSortAndSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26.0, 12.0, 26.0, 20.0),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 排序筛选
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("排序类型", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                const SizedBox(width: 10),
                ComboBox<String>(
                  value: _sortType,
                  items: const [
                    ComboBoxItem(value: "title", child: Text("标题排序", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))),
                    ComboBoxItem(value: "subtitle", child: Text("副标题排序", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))),
                    ComboBoxItem(value: "album", child: Text("专辑排序", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))),
                    ComboBoxItem(value: "artist", child: Text("艺术家排序", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortType = value);
                    }
                  },
                ),
                const SizedBox(width: 20),
                const Text("顺序", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                const SizedBox(width: 10),
                ComboBox<String>(
                  value: _sortOrder,
                  items: const [
                    ComboBoxItem(value: "asc", child: Text("升序", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))),
                    ComboBoxItem(value: "desc", child: Text("降序", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortOrder = value);
                    }
                  },
                ),
              ],
            ),
            // 歌曲搜索栏
            SizedBox(
              height: 38,
              width: 200,
              child: TextBox(
                placeholder: "搜索",
                placeholderStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'),
                onChanged: (text) {
                  setState(() => _searchQuery = text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // [音乐页面]歌曲列表
  Widget _songsContent({required LibraryController controller, required List<SongModel> displaySongs}) {
    // 加载中
    if (controller.isLoading) {
      return const Center(child: ProgressRing());
    }
 
    // 有错误
    if (controller.errorMessage != null) {
      return Center(child: Text("加载失败: ${controller.errorMessage}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }

    // 没有歌曲时提示
    if(controller.allSongs.isEmpty) {
      return const Center(child: Text("暂无歌曲", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }

    // 搜索无结果
    if(displaySongs.isEmpty) {
      return const Center(child: Text("没有找到匹配的歌曲", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')));
    }

    // 显示歌曲列表
    return ListView.builder(
      itemCount: displaySongs.isEmpty ? 0 : displaySongs.length + 1,
      itemBuilder: (context, index) {
        if (displaySongs.isEmpty) return const SizedBox.shrink();
        if (index == displaySongs.length) {
          return const SizedBox(height: 100.0);
        }
        final song = displaySongs[index];
        return SongCard(song: song, songs: displaySongs, index: index);
      },
    );
  }
}
