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
          buildBackground(),

          Column(
            children: [
              // 窗口标题栏
              buildWindowCaption(),

              // 窗口内容
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '造物主壁纸',
                    style: TextStyle(fontSize: 40, color: Colors.black),
                  ),
                ),
              ),
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

  /// 构建窗口标题栏
  Widget buildWindowCaption() {
    return SizedBox(
      height: 40,
      child: WindowCaption(
        title: Text(
          '造物主壁纸',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'MiSans', // 这个组件好像不支持从主题中获取字体，只能手动指定
          ),
        ),
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
      ),
    );
  }
}
