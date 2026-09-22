import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  AudioService() { _player.setReleaseMode(ReleaseMode.stop); }

  /// 播放指定文件
  Future<void> playFile(String filePath) async {
    await _player.play(DeviceFileSource(filePath));
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.resume();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  // ---- 流 ----
  Stream<Duration> get positionStream => _player.onPositionChanged;
  Stream<Duration> get durationStream => _player.onDurationChanged;
  Stream<PlayerState> get playerStateStream => _player.onPlayerStateChanged;

  /// 播放完成事件
  Stream<void> get completedStream => _player.onPlayerComplete;

  void dispose() {
    _player.dispose().catchError((e) {
      // ignore: avoid_print
      print('AudioPlayer dispose 错误: $e');
    });
  }
}