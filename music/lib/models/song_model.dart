import 'dart:typed_data';

class SongModel {
  // 歌曲ID
  final String id;
  // 文件名
  final String fileName;
  // 文件绝对路径
  final String filePath;
  // 歌曲标题 (歌曲名)
  final String? title;
  // 歌曲副标题
  final String? subtitle;
  // 艺术家
  final String? artist;
  // 所属专辑
  final String? album;
  // 音轨号
  final int? trackNumber;
  // 歌曲时长
  final Duration duration;
  // 内嵌封面
  final Uint8List? coverArt;
  // 内嵌歌词
  final String? lyric;

  // 构造函数
  const SongModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.title,
    this.subtitle,
    this.artist,
    this.album,
    this.trackNumber,
    required this.duration,
    this.coverArt,
    this.lyric,
  });

  // 标题显示
  String get displayTitle => title ?? fileName;

  // 歌曲时长显示
  String get durationText {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
