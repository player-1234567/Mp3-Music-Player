import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:music/models/song_model.dart';

// 本地音乐服务: 负责扫描文件夹并解析文件夹内的音频文件
class LibraryService {
  // 支持的音频格式: MP3
  static final List<String> _supportedExtensions = ['.mp3'];

  // 扫描指定文件夹返回歌曲列表
  Future<List<SongModel>> scanFolder(
    String folderPath, {
    bool includeImages = true,
  }) async {
    final List<SongModel> songs = [];
    final directory = Directory(folderPath);
    if (!await directory.exists()) return songs;
    await for (var entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        final ext = path.extension(entity.path).toLowerCase();
        if (_supportedExtensions.any((e) => ext == e)) {
          final song = await _parseFile(entity, includeImages: includeImages);
          if (song != null) {
            songs.add(song);
          }
        }
      }
    }
    return songs;
  }

  // 解析单个音频文件
  Future<SongModel?> _parseFile(File file, {bool includeImages = true}) async {
    try {
      final metadata = readAllMetadata(file, getImage: includeImages);
      if (metadata is! Mp3Metadata) return null;
      final id = file.path;
      final filePath = file.path;
      final fileName = path.basename(filePath);
      return SongModel(
        id: id,
        fileName: fileName,
        filePath: filePath,
        title: metadata.songName,
        subtitle: metadata.subtitle,
        artist: metadata.leadPerformer,
        album: metadata.album,
        trackNumber: metadata.trackNumber,
        duration: metadata.duration ?? Duration.zero,
        coverArt: metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null,
        lyric: metadata.lyric,
      );
    } catch (e) {
      // ignore: avoid_print
      print('跳过文件 ${file.path}: $e');
      return null;
    }
  }
}
