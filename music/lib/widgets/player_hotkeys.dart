import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:music/controllers/player_controller.dart';
import 'package:provider/provider.dart';

/// 快捷键组件(包裹main_page和player_page以确保生效)
class PlayerHotkeys extends StatelessWidget {
  final Widget child;
  const PlayerHotkeys({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        // 只处理按下事件，忽略抬起事件
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final player = context.read<PlayerController>();
        // 空格：播放/暂停
        if (event.logicalKey == LogicalKeyboardKey.space) {
          player.togglePlayPause();
          return KeyEventResult.handled;
        }
        // 左箭头：上一首
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          player.playPrevious();
          return KeyEventResult.handled;
        }
        // 右箭头：下一首
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          player.playNext();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}