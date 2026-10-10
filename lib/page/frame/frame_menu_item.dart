import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// 导航菜单项
class FrameMenuItem extends StatelessWidget {
  const FrameMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isSelected = false,
  });

  /// 图标
  final List<List<dynamic>> icon;

  /// 标题
  final String title;

  /// 是否选中
  final bool isSelected;

  /// 点击事件
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 前景色
    final Color foregroundColor;

    // 装饰器
    BoxDecoration? decoration;

    // 判断是否选中项
    if (isSelected) {
      foregroundColor = Colors.white;
      decoration = BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      );
    } else {
      foregroundColor = Colors.black;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        hoverColor: Colors.black12, // 悬浮时显示的颜色
        borderRadius: BorderRadius.circular(8),
        onTap: onTap, // 必须有 onTap，否则悬浮不生效
        child: Container(
          decoration: decoration,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: HugeIcon(icon: icon, size: 18, color: foregroundColor),
              ),
              Text(
                title,
                style: TextStyle(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
