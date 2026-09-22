import 'package:fluent_ui/fluent_ui.dart';
import 'package:music/controllers/library_controller.dart';
import 'package:music/controllers/player_controller.dart';
import 'package:music/controllers/setting_controller.dart';
import 'package:music/pages/main_page.dart';
import 'package:music/services/storage_service.dart';
import 'package:music/utils/theme_util.dart';
import 'package:music/utils/window_manager_util.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManagerUtil.setupWindow();
  await StorageService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingController()),
        ChangeNotifierProvider(create: (_) => LibraryController()),
        ChangeNotifierProvider(create: (_) => PlayerController()),
      ],
      child: const MusicApp(),
    ),
  );
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingController>(
      builder: (context, setting, child) {
        return FluentApp(
          title: "Mp3 Music Player",
          theme: setting.transparency == 'opaque' ? lightTheme : lightTransparentTheme,
          darkTheme: setting.transparency == 'opaque' ? darkTheme : darkTransparentTheme,
          themeMode: setting.theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
          home: MainPage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
