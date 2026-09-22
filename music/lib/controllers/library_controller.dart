import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/models/song_model.dart';
import 'package:music/services/library_service.dart';

// 本地音乐控制器
class LibraryController extends ChangeNotifier {
  final LibraryService _service = LibraryService();

  // 私有状态
  List<SongModel> _allSongs = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFolderPath = '';

  // 公共 Getters（UI 通过它们读取数据）
  List<SongModel> get allSongs => _allSongs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFolderPath => _currentFolderPath;
  int get songCount => _allSongs.length;

  // ---- 核心方法 ----

  /// 扫描指定文件夹
  Future<void> loadSongs(
    String folderPath, {
    bool includeImages = true,
  }) async {
    // 如果路径为空或与当前路径相同，不重复扫描
    if (folderPath.isEmpty) return;
    if (_currentFolderPath == folderPath && _allSongs.isNotEmpty) return;

    // 开始加载
    _isLoading = true;
    _errorMessage = null;
    _currentFolderPath = folderPath;
    notifyListeners();

    try {
      final songs = await _service.scanFolder(
        folderPath,
        includeImages: includeImages,
      );
      _allSongs = songs;
    } catch (e) {
      _errorMessage = e.toString();
      _allSongs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索歌曲（按标题或艺术家）
  List<SongModel> search(String query) {
    if (query.isEmpty) return _allSongs;
    final lowerQuery = query.toLowerCase();
    return _allSongs.where((song) {
      return song.displayTitle.toLowerCase().contains(lowerQuery) ||
          (song.artist?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// 按艺术家分组（用于艺术家页面）
  Map<String, List<SongModel>> getSongsGroupedByArtist() {
    final map = <String, List<SongModel>>{};
    for (var song in _allSongs) {
      final key = song.artist ?? '未知艺术家';
      map.putIfAbsent(key, () => []).add(song);
    }
    return map;
  }

  /// 按专辑分组（用于专辑页面）
  Map<String, List<SongModel>> getSongsGroupedByAlbum() {
    final map = <String, List<SongModel>>{};
    for (var song in _allSongs) {
      final key = song.album ?? '未知专辑';
      map.putIfAbsent(key, () => []).add(song);
    }
    return map;
  }

  /// 清空数据
  void clear() {
    _allSongs = [];
    _currentFolderPath = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// 刷新当前文件夹（重新扫描）
  Future<void> refreshSongs() async {
    if (_currentFolderPath.isNotEmpty) {
      await loadSongs(_currentFolderPath);
    }
  }

  // 生命周期
  @override
  void dispose() {
    // 如果有需要释放的资源，在这里处理
    super.dispose();
  }
}
