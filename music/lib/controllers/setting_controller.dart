import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/services/storage_service.dart';

class SettingController extends ChangeNotifier {
  final StorageService _storage = StorageService();

  String _theme = 'dark';
  String _transparency = 'opaque';
  int _fontSize = 16;
  int _fontWeight = 400;
  String _musicFolderPath = '';

  SettingController() {
    _loadFromStorage();
  }

  // 从存储加载
  void _loadFromStorage() {
    _theme = _storage.getString('theme', defaultValue: 'light');
    _transparency = _storage.getString('transparency', defaultValue: 'opaque');
    _fontSize = _storage.getInt('fontSize', defaultValue: 16);
    _fontWeight = _storage.getInt('fontWeight', defaultValue: 400);
    _musicFolderPath = _storage.getString('musicFolder', defaultValue: '');
  }

  String get theme => _theme;
  String get transparency => _transparency;
  int get fontSize => _fontSize;
  int get fontWeight => _fontWeight;
  String get musicFolderPath => _musicFolderPath;

  // 主题切换
  void setTheme(String value) {
    if (_theme == value) return;
    _theme = value;
    _storage.setString('theme', value);
    notifyListeners();
  }

  // 透明度切换
  void setTransparency(String value) {
    if (_transparency == value) return;
    _transparency = value;
    _storage.setString('transparency', value);
    notifyListeners();
  }

  // 歌词字体大小
  void setFontSize(int value) {
    if (_fontSize == value) return;
    _fontSize = value;
    _storage.setInt('fontSize', value);
    notifyListeners();
  }

  // 歌词字重
  void setFontWeight(int value) {
    if (_fontWeight == value) return;
    _fontWeight = value;
    _storage.setInt('fontWeight', value);
    notifyListeners();
  }

  // 选择音乐文件夹
  void setMusicFolder(String path) {
    if (_musicFolderPath == path) return;
    _musicFolderPath = path;
    _storage.setString('musicFolder', path);
    notifyListeners();
  }
}
