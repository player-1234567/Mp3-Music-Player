import 'package:fluent_ui/fluent_ui.dart';

final FluentThemeData lightTheme = FluentThemeData(
  visualDensity: VisualDensity.standard,
  fontFamily: "NotoSansCJKsc",
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
  navigationPaneTheme: const NavigationPaneThemeData(backgroundColor: Color.fromARGB(255, 240, 240, 240)),
  cardColor: const Color.fromARGB(255, 255, 255, 255),
);

final FluentThemeData lightTransparentTheme = FluentThemeData(
  visualDensity: VisualDensity.standard,
  fontFamily: "NotoSansCJKsc",
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color.fromARGB(0, 0, 0, 0),
  navigationPaneTheme: const NavigationPaneThemeData(backgroundColor: Color.fromARGB(0, 0, 0, 0)),
  cardColor: const Color.fromARGB(0, 0, 0, 0),
);

final FluentThemeData darkTheme = FluentThemeData(
  visualDensity: VisualDensity.standard,
  fontFamily: "NotoSansCJKsc",
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 39, 39, 39),
  navigationPaneTheme: const NavigationPaneThemeData(backgroundColor: Color.fromARGB(255, 32, 32, 32)),
  cardColor: const Color.fromARGB(255, 50, 50, 50),
);

final FluentThemeData darkTransparentTheme = FluentThemeData(
  visualDensity: VisualDensity.standard,
  fontFamily: "NotoSansCJKsc",
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(0, 0, 0, 0),
  navigationPaneTheme: const NavigationPaneThemeData(backgroundColor: Color.fromARGB(0, 0, 0, 0)),
  cardColor: const Color.fromARGB(0, 0, 0, 0),
);
