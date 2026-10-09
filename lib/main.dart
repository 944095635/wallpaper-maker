import 'package:flutter/material.dart';
import 'package:nativeapi_flutter/nativeapi_flutter.dart';
import 'package:wallpaper_maker/page/frame_page.dart';

void main() {
  final window = WindowManager.instance.getCurrent();
  if (window != null) {
    window.title = '造物主壁纸';
    window.titleBarStyle = TitleBarStyle.hidden;
    // 3240 * 1876 | 3240/2 = 1620 / 1876/2 = 938.3
    window.setSize(const Size(1620, 938).toNative(), false);
    window.minimumSize = const Size(640, 480).toNative();
    window.center();
    window.show();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '造物主壁纸',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        fontFamily: 'Microsoft YaHei',
        colorScheme: ColorScheme.dark(surface: Colors.black),
      ),
      locale: const Locale("zh", "CN"),
      home: const FramePage(),
    );
  }
}
