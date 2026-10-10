import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wallpaper_maker/page/frame/frame_menu_item.dart';
import 'package:wallpaper_maker/page/home/home_page.dart';

class FramePage extends StatefulWidget {
  const new({super.key});

  @override
  State<FramePage> createState() => _FramePageState();
}

class _FramePageState extends State<FramePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: .expand,
        children: [
          // 背景图片
          buildBackground(),

          Column(
            children: [
              // 窗口标题栏
              SizedBox(
                height: 46,
                child: WindowCaption(
                  title: Text(
                    '造物主壁纸门',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'MiSans', // 小米字体 必须设置，脱离Theme区域
                    ),
                  ),
                  brightness: Brightness.light,
                  // backgroundColor: Colors.transparent,
                  // brightness: Brightness.light,
                ),
              ),

              // 导航菜单
              buildMenu(),

              // 窗口内容
              Expanded(child: buildContent()),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建背景图片
  Widget buildBackground() {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, .95),
            Color.fromRGBO(255, 255, 255, 1),
          ],
          stops: [0, .8],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
      },
      blendMode: BlendMode.srcOver,
      child: Image.asset(
        'images/bg.jpg',
        fit: BoxFit.cover,
        cacheWidth: 1600,
      ),
    );
  }

  /// 导航菜单
  Widget buildMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        spacing: 10,
        children: [
          FrameMenuItem(
            icon: HugeIcons.strokeRoundedSaturn,
            title: '今日推荐',
            isSelected: true,
          ),
          FrameMenuItem(
            icon: HugeIcons.strokeRoundedImages,
            title: '我的壁纸',
          ),
          FrameMenuItem(
            icon: HugeIcons.strokeRoundedDownload05,
            title: '正在下载',
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
            onPressed: () {},
            child: HugeIcon(icon: HugeIcons.strokeRoundedDownload05),
          ),
          ElevatedButton(
            onPressed: () {},
            child: HugeIcon(icon: HugeIcons.strokeRoundedDownload05),
          ),
        ],
      ),
    );
  }

  /// 右侧内容区域
  Widget buildContent() {
    return HomePage();
  }
}
