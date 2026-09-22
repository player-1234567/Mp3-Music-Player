import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:music/controllers/player_controller.dart';

/// 歌曲播放时间, 结束时间组件
class PlayerTimeText extends StatelessWidget {
  const PlayerTimeText({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    return Text(
      "${player.positionText} / ${player.durationText}",
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        fontFamily: 'NotoSansCJKsc',
      ), 
    );
  }
}