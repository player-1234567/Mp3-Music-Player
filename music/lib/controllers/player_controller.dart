import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/models/song_model.dart';
import 'package:music/services/audio_service.dart';
import 'package:music/utils/lyric_parser.dart';

class PlayerController extends ChangeNotifier {
  final AudioService _audioService = AudioService();

  

  // 状态
  List<SongModel> _playlist = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showCover = true;
  int _lyricAlign = 1;
  bool _isSwitchingSong = false;
  String? _cachedLyricSongId;      // 缓存对应的 song.id
  List<LyricLine>? _cachedLyricLines;  // 缓存解析结果

  bool _disposed = false;
  void _safeNotify() { if(!_disposed) notifyListeners(); }

  // Getters
  List<SongModel> get playlist => _playlist;
  SongModel? get currentSong => (_currentIndex >= 0 && _currentIndex < _playlist.length) ? _playlist[_currentIndex] : null;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    final p = _position.inMilliseconds / _duration.inMilliseconds;
    return p.clamp(0.0, 1.0);
  }

  String get positionText => _format(_position);
  String get durationText => _format(_duration);
  bool get showCover => _showCover;
  int get lyricAlign => _lyricAlign;

  List<LyricLine> get lyricLines {
    final song = currentSong;
    if (song == null || song.lyric == null || song.lyric!.isEmpty) {
      _cachedLyricSongId = null;
      _cachedLyricLines = null;
      return const [];
    }
    if (_cachedLyricSongId != song.id) {
      _cachedLyricSongId = song.id;
      _cachedLyricLines = LyricParser.parse(song.lyric!);
    }
    return _cachedLyricLines ?? const [];
  }

  PlayerController() {
    _initStreams();
  }


  final List<StreamSubscription> _subscriptions = [];

  void _initStreams() {
    // 播放位置变化
    _subscriptions.add(
      _audioService.positionStream.listen((pos) {
        _position = pos;
        _safeNotify();
      })
    );

    // 歌曲时长变化
    _subscriptions.add(
      _audioService.durationStream.listen((dur) {
        if(dur.inMilliseconds > 0) {
          _duration = dur;
          _safeNotify();
        }
      })
    );
    
    // 播放/暂停状态
    _subscriptions.add(
      _audioService.playerStateStream.listen((state) {
        _isPlaying = state == PlayerState.playing;
        _safeNotify();
      })
    );
  
    // 播放完成事件
    _subscriptions.add(
      _audioService.completedStream.listen((_) async {
        if (_isSwitchingSong) return;
        final remaining = _duration.inMilliseconds - _position.inMilliseconds;
        if (remaining < 1500) {
          _isSwitchingSong = true;
          try { await playNext(); } finally { _isSwitchingSong = false; }
        }
      })
    );
    
  }


  /*---------- 播放控制 ----------*/

  // 切换到指定索引(统一处理状态重置, 播放)
  Future<void> _switchTo(int index) async {
    _currentIndex = index;
    _position = Duration.zero;
    _duration = _playlist[index].duration;
    _safeNotify();
    await _playFile(_playlist[index].filePath);
  }

  // 播放某一首歌(传入当前页面的整个歌曲列表, 索引)
  Future<void> playSong(List<SongModel> songs, int index) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) return;
    _playlist = List.from(songs); // 拷贝一份，避免外部修改
    await _switchTo(index);
  }
  
  // 播放对应音乐文件
  Future<void> _playFile(String path) async {
    try {
      await _audioService.playFile(path);
    } catch (e) {
      // ignore: avoid_print
      print('播放失败: $e');
    }
  }

  // 上一首
  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    await _switchTo((_currentIndex - 1 + _playlist.length) % _playlist.length);
  }

  // 播放/暂停
  Future<void> togglePlayPause() async {
    if (currentSong == null) return;
    isPlaying ? await _audioService.pause() : await _audioService.resume();
  }
  
  // 下一首
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    await _switchTo((_currentIndex + 1) % _playlist.length);
  }

  // 跳转到指定进度
  Future<void> seekTo(Duration position) => _audioService.seek(position);

 
  /*---------- 播放栏UI ----------*/

  // 调节外观(封面/歌词)
  void toggleShowCover(bool value) {
    _showCover = value;
    _safeNotify();
  }
  
  // 调节歌词(左中右)显示
  void cycleLyricAlign() {
    _lyricAlign = (_lyricAlign + 1) % 3;
    _safeNotify();
  }

  // 格式化时长为 mm:ss
  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _disposed = true;
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _audioService.dispose();
    super.dispose();
  }
}