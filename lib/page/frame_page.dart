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
      body: Column(
        children: [
          // 窗口标题栏
          buildWindowCaption(),

          // 窗口内容
          Expanded(child: Container()),
        ],
      ),
    );
  }

  /// 构建窗口标题栏
  Widget buildWindowCaption() {
    return SizedBox(
      height: 48,
      child: WindowCaption(
        title: Text('造物主壁纸'),
        brightness: Theme.of(context).brightness,
      ),
    );
  }
}
