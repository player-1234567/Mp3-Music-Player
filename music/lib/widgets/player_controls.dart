import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/player_controller.dart';
import 'package:provider/provider.dart';

/// 通用按钮组件: 上一首按钮, 播放/暂停按钮, 下一首按钮
class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 上一首按钮
        SizedBox(
          height: 40.0,
          width: 40.0,
          child: IconButton(
            icon: const Icon(WindowsIcons.previous),
            onPressed: player.playPrevious,
          ),
        ),
        const SizedBox(width: 4.0),
        // 暂停播放按钮
        SizedBox(
          height: 40.0,
          width: 40.0,
          child: IconButton(
            icon: Icon(player.isPlaying ? WindowsIcons.pause : WindowsIcons.play),
            onPressed: player.togglePlayPause,
          ),
        ),
        const SizedBox(width: 4.0),
        // 下一首按钮
        SizedBox(
          height: 40.0,
          width: 40.0,
          child: IconButton(
            icon: const Icon(WindowsIcons.next),
            onPressed: player.playNext,
          ),
        ),
      ]
    );
  }
}