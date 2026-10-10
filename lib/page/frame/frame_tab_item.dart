import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class FrameTabItem extends StatelessWidget {
  const new({
    super.key,
    required this.icon,
    required this.title,
  });

  /// 图标
  final List<List<dynamic>> icon;

  /// 标题
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: HugeIcon(icon: icon, size: 18),
        ),
        Text(title),
      ],
    );
  }
}
