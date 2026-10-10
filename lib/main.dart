import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wallpaper_maker/page/frame/frame_page.dart';

void main() {
  final window = WindowManager.instance.getCurrent();
  if (window != null) {
    // 3240 * 1876 | 3240/2 = 1620 / 1876/2 = 938.3

    // 设备屏幕缩放比例
    final devicePixelRatio =
        PlatformDispatcher.instance.displays.first.devicePixelRatio;

    // 窗口 宽度
    final windowWidth = 1944 / devicePixelRatio;
    // 窗口 高度
    final windowHeight = 1120 / devicePixelRatio;
    // 窗口大小
    final windowSize = Size(windowWidth, windowHeight);

    window.title = '造物主壁纸';
    window.titleBarStyle = TitleBarStyle.hidden;
    window.setSize(windowSize.toNative(), false);
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
      themeMode: ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'MiSans', // 小米字体
        colorScheme: ColorScheme.light(),
        appBarTheme: AppBarTheme(
          toolbarHeight: 40,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale("zh", "CN"),
      home: const FramePage(),
    );
  }
}
