/// 单行歌词
class LyricLine {
  final Duration time;
  final String text;          // 主歌词
  final String? translation;  // 同时间轴的翻译

  const LyricLine({
    required this.time,
    required this.text,
    this.translation,
  });
}

class LyricParser {
  static final _reg = RegExp(r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]');

  static List<LyricLine> parse(String lrc) {
    final map = <Duration, List<String>>{};

    for (final rawLine in lrc.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final matches = _reg.allMatches(line);
      if (matches.isEmpty) continue;

      // 时间戳之后的文本才是歌词
      final text = line.substring(matches.last.end).trim();
      if (text.isEmpty) continue;

      for (final m in matches) {
        final min = int.parse(m.group(1)!);
        final sec = int.parse(m.group(2)!);
        final msStr = m.group(3) ?? '0';
        // 兼容 [mm:ss.xx] 和 [mm:ss.xxx]
        final ms = msStr.length == 3
            ? int.parse(msStr)
            : int.parse(msStr) * 10;
        final time = Duration(minutes: min, seconds: sec, milliseconds: ms);
        map.putIfAbsent(time, () => []).add(text);
      }
    }

    final keys = map.keys.toList()..sort();
    return keys.map((t) {
      final texts = map[t]!;
      return LyricLine(
        time: t,
        text: texts.first,
        translation: texts.length > 1 ? texts.sublist(1).join(' / ') : null,
      );
    }).toList();
  }

  /// 根据播放位置找到当前歌词的索引
  static int indexAt(List<LyricLine> lines, Duration position) {
    if (lines.isEmpty) return -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (position >= lines[i].time) return i;
    }
    return 0;
  }
}