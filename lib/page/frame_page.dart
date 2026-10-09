import 'package:flutter/material.dart';
import 'package:nativeapi_flutter/nativeapi_flutter.dart';

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
      appBar: AppBar(
        title: Text('造物主壁纸'),
        flexibleSpace: DragToMoveArea(
          child: SizedBox.expand(),
        ),
      ),
      body: SizedBox.expand(),
    );
  }
}
