import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // 软件根目录下的 userdata 文件夹路径
  late final String _userDataPath;

  // 完整的 settings.json 文件路径
  late final String _settingsFilePath;

  // 内存缓存（避免每次都读磁盘）
  Map<String, dynamic> _cache = {};

  /// 初始化：创建 userdata 文件夹和 settings.json（如果不存在）
  Future<void> init() async {
    // 获取软件根目录（可执行文件所在目录）
    final exeDir = Directory(Platform.resolvedExecutable).parent;
    _userDataPath = path.join(exeDir.path, 'userdata');

    // 创建 userdata 文件夹（如果不存在）
    final userDataDir = Directory(_userDataPath);
    if (!await userDataDir.exists()) {
      await userDataDir.create(recursive: true);
    }

    _settingsFilePath = path.join(_userDataPath, 'settings.json');

    // 如果 settings.json 不存在，创建一个空文件
    if (!await File(_settingsFilePath).exists()) {
      await File(_settingsFilePath).writeAsString('{}');
    }

    // 加载配置到内存缓存
    await _loadCache();
  }

  /// 从磁盘加载 JSON 到内存缓存
  Future<void> _loadCache() async {
    try {
      final content = await File(_settingsFilePath).readAsString();
      _cache = jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      _cache = {};
    }
  }

  /// 将内存缓存写入磁盘
  Future<void> _saveCache() async {
    final content = jsonEncode(_cache);
    await File(_settingsFilePath).writeAsString(content);
  }

  // ---- 公共读写接口 ----

  /// 读取字符串（带默认值）
  String getString(String key, {String defaultValue = ''}) {
    return _cache[key]?.toString() ?? defaultValue;
  }

  /// 读取整数（带默认值）
  int getInt(String key, {int defaultValue = 0}) {
    return _cache[key] as int? ?? defaultValue;
  }

  /// 读取布尔值（带默认值）
  bool getBool(String key, {bool defaultValue = false}) {
    return _cache[key] as bool? ?? defaultValue;
  }

  /// 读取 Map（带默认值）
  Map<String, dynamic> getMap(
    String key, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    return _cache[key] as Map<String, dynamic>? ?? defaultValue;
  }

  /// 写入字符串
  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    await _saveCache();
  }

  /// 写入整数
  Future<void> setInt(String key, int value) async {
    _cache[key] = value;
    await _saveCache();
  }

  /// 写入布尔值
  Future<void> setBool(String key, bool value) async {
    _cache[key] = value;
    await _saveCache();
  }

  /// 写入 Map
  Future<void> setMap(String key, Map<String, dynamic> value) async {
    _cache[key] = value;
    await _saveCache();
  }
}
