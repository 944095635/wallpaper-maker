import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wallpaper_maker/page/donwload/download_page.dart';
import 'package:wallpaper_maker/page/frame/frame_menu_item.dart';
import 'package:wallpaper_maker/page/frame/frame_tab_item.dart';
import 'package:wallpaper_maker/page/home/home_page.dart';
import 'package:wallpaper_maker/page/local/local_page.dart';
import 'package:wallpaper_maker/page/setting/setting_page.dart';

class FramePage extends StatefulWidget {
  const new({super.key});

  @override
  State<FramePage> createState() => _FramePageState();
}

class _FramePageState extends State<FramePage> {
  /// 选中的菜单
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          fit: .expand,
          children: [
            // 背景图片
            buildBackground(),

            Column(
              crossAxisAlignment: .stretch,
              children: [
                // 窗口标题栏
                SizedBox(
                  height: 40,
                  child: WindowCaption(
                    title: Text(
                      '造物主壁纸',
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
                TabBar(
                  isScrollable: true,
                  tabAlignment: .start,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  tabs: [
                    FrameTabItem(
                      icon: HugeIcons.strokeRoundedSaturn,
                      title: '今日推荐',
                    ),
                    FrameTabItem(
                      icon: HugeIcons.strokeRoundedImages,
                      title: '我的壁纸',
                    ),
                    FrameTabItem(
                      icon: HugeIcons.strokeRoundedDownload05,
                      title: '正在下载',
                    ),
                    FrameTabItem(
                      icon: HugeIcons.strokeRoundedSetting06,
                      title: '系统设置',
                    ),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    children: const [
                      HomePage(),
                      LocalPage(),
                      DownloadPage(),
                      SettingPage(),
                    ],
                  ),
                ),

                // 窗口内容
                // Expanded(child: buildContent()),
              ],
            ),
          ],
        ),
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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: .start,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            tabs: [
              FrameTabItem(
                icon: HugeIcons.strokeRoundedSaturn,
                title: '今日推荐',
              ),
              FrameTabItem(
                icon: HugeIcons.strokeRoundedImages,
                title: '我的壁纸',
              ),
              FrameTabItem(
                icon: HugeIcons.strokeRoundedDownload05,
                title: '正在下载',
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                HomePage(),
                HomePage(),
                HomePage(),
              ],
            ),
          ),
        ],
      ),
    );

    // 自定义菜单
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        spacing: 10,
        children: [
          FrameMenuItem(
            icon: HugeIcons.strokeRoundedSaturn,
            title: '今日推荐',
            isSelected: _selectedIndex == 0,
            onTap: () => _selectMenuItem(0),
          ),
          FrameMenuItem(
            icon: HugeIcons.strokeRoundedImages,
            title: '我的壁纸',
            isSelected: _selectedIndex == 1,
            onTap: () => _selectMenuItem(1),
          ),
          FrameMenuItem(
            icon: HugeIcons.strokeRoundedDownload05,
            title: '正在下载',
            isSelected: _selectedIndex == 2,
            onTap: () => _selectMenuItem(2),
          ),
        ],
      ),
    );
  }

  /// 右侧内容区域
  Widget buildContent() {
    return HomePage();
  }

  /// 切换选中的菜单
  void _selectMenuItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: CupertinoSlidingSegmentedControl<int>(
//             groupValue: _selectedIndex,
//             proportionalWidth: false,
//             // backgroundColor: Colors.transparent,
//             children: {
//               0: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   spacing: 4,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const HugeIcon(
//                       icon: HugeIcons.strokeRoundedSaturn,
//                       size: 19,
//                     ),
//                     Text('今日推荐'),
//                   ],
//                 ),
//               ),
//               1: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   spacing: 4,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const HugeIcon(
//                       icon: HugeIcons.strokeRoundedImages,
//                       size: 19,
//                     ),
//                     Text('我的壁纸'),
//                   ],
//                 ),
//               ),
//               2: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   spacing: 4,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const HugeIcon(
//                       icon: HugeIcons.strokeRoundedDownload05,
//                       size: 19,
//                     ),
//                     Text('正在下载'),
//                   ],
//                 ),
//               ),
//             },
//             onValueChanged: (value) {
//               setState(() {
//                 _selectedIndex = value ?? 0;
//               });
//             },
//           ),
//         ),
//       ),

//       SizedBox(
//         height: 10,
//       ),
