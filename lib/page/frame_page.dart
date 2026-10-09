import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

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
          ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [
                  const Color.fromRGBO(255, 255, 255, .95),
                  const Color.fromRGBO(255, 255, 255, 1),
                ],
                stops: [0, .8],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(rect);
            },
            blendMode: BlendMode.srcOver, // shader 画在 child 上面
            child: Image.asset(
              'images/bg.jpg',
              fit: BoxFit.cover,
              cacheWidth: 1600,
            ),
          ),

          Column(
            children: [
              // 窗口标题栏
              buildWindowCaption(),

              // 窗口内容
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建窗口标题栏
  Widget buildWindowCaption() {
    return SizedBox(
      height: 40,
      child: WindowCaption(
        title: Text('造物主壁纸'),
        backgroundColor: Colors.transparent,
        brightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
