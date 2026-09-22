import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/library_controller.dart';
import 'package:music/controllers/setting_controller.dart';
import 'package:provider/provider.dart';

final Map<String, String> themeMap = {
  'light': '浅色主题',
  'dark': '深色主题',
};
final Map<String, String> transparencyMap = {
  'opaque': '不透明',
  'transparent': '透明',
};
final Map<int, String> fontSizeMap = {
  14: '14',
  16: '16',
  18: '18',
  20: '20',
  22: '22',
  24: '24',
  26: '26',
  28: '28',
  30: '30',
  32: '32',
  34: '34',
  36: '36',
  38: '38',
  40: '40',
};
final Map<int, String> fontWeightMap = {
  100: '[ w100 ]',
  200: '[ w200 ]',
  300: '[ w300 ]',
  400: '[ w400 ]',
  500: '[ w500 ]',
  600: '[ w600 ]',
  700: '[ w700 ]',
  800: '[ w800 ]',
  900: '[ w900 ]',
};

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingController>();
    return ScaffoldPage(
      header: PageHeader(title: const Text("设置", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'NotoSansCJKsc'))),
      content: SizedBox.expand(
        child: ListView(
          children: [
            _settingTitle("常规设置"),
            // 主题
            _settingComboboxCard(
              label: "主题",
              value: settings.theme,
              comboBoxMap: themeMap,
              onChanged: (value) => context.read<SettingController>().setTheme(value!)
            ),
            // 透明度
            _settingComboboxCard(
              label: "透明度",
              value: settings.transparency,
              comboBoxMap: transparencyMap,
              onChanged: (value) => context.read<SettingController>().setTransparency(value!)
            ),
            // 本地音乐文件夹
            _settingMusicFolderCard(
              label: "本地音乐文件夹",
              buttonText: "选择文件夹",
              musicFolderPath: settings.musicFolderPath,
              onPressed: () async {
                String? selectedDirectory = await FilePicker.getDirectoryPath();
                if (!context.mounted) return;
                if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
                  context.read<SettingController>().setMusicFolder(
                    selectedDirectory,
                  );
                  context.read<LibraryController>().loadSongs(
                    selectedDirectory,
                    includeImages: true,
                  );
                }
              },
            ),
            _settingTitle("歌词样式"),
            // 字体大小
            _settingComboboxCard(
              label: "字体大小",
              value: settings.fontSize,
              comboBoxMap: fontSizeMap,
              onChanged: (value) => context.read<SettingController>().setFontSize(value!),
            ),
            // 字体字重
            _settingComboboxCard(
              label: "字体字重",
              value: settings.fontWeight,
              comboBoxMap: fontWeightMap,
              onChanged: (value) => context.read<SettingController>().setFontWeight(value!),
            ),
            _settingTitle("快捷键"),
            _settingShortcutCard(
              label: "开始 / 暂停",
              shortcutsText: "[ 空格键 ]",
              shortcutIcon: WindowsIcons.underscore_space,
            ),
            _settingShortcutCard(
              label: "上一首歌曲",
              shortcutsText: "[ 左箭头键 ]",
              shortcutIcon: WindowsIcons.left_arrow_key_time0,
            ),
            _settingShortcutCard(
              label: "下一首歌曲",
              shortcutsText: "[ 右箭头键 ]",
              shortcutIcon: WindowsIcons.right_arrow_key_time0,
            ),
            const SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }

  // [设置页面]标题组件
  Widget _settingTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26.0, 12.0, 26.0, 0.0),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'NotoSansCJKsc')),
    );
  }
  
  // [设置页面]下拉菜单组件
  Widget _settingComboboxCard<T>({required String label, required T? value, required Map comboBoxMap, required ValueChanged<T?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26.0, 8.0, 26.0, 0.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
              SizedBox(
                height: 38.0,
                child: ComboBox<T>(
                  value: value,
                  items: comboBoxMap.entries.map((entry) {
                    return ComboBoxItem<T>(
                      value: entry.key,
                      child: Text(entry.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [设置页面]本地文件夹卡片组件
  Widget _settingMusicFolderCard({required String label, required String musicFolderPath, required void Function()? onPressed, required String buttonText}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26.0, 8.0, 26.0, 0.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 600,
                    child: Text(
                      musicFolderPath,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 38,
                    child: Button(
                      onPressed: onPressed,
                      child: Text(buttonText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc'))
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [设置页面]快捷键卡片组件
  Widget _settingShortcutCard({required String label, required String shortcutsText, required IconData shortcutIcon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26.0, 8.0, 26.0, 0.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(
                height: double.infinity,
                child: Row(
                  children: [
                    Text(shortcutsText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansCJKsc')),
                    const SizedBox(width: 10),
                    Icon(shortcutIcon, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
