import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> wallpapers = [
    "https://haowallpaper.com/link/common/file/getCroppingImg/19705830074569600",
    "https://haowallpaper.com/link/common/file/getCroppingImg/18601605145677184",
    "https://haowallpaper.com/link/common/file/getCroppingImg/19683678457058176",
    "https://haowallpaper.com/link/common/file/getCroppingImg/19767417784652672",
    "https://haowallpaper.com/link/common/file/getCroppingImg/19767398619173760",
    "https://haowallpaper.com/link/common/file/getCroppingImg/19705818799494016",
    "https://haowallpaper.com/link/common/file/getCroppingImg/16202544571600256",

  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: wallpapers.length,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
        maxCrossAxisExtent: 320,
      ),
      itemBuilder: (context, index) {
        final wallpaper = wallpapers[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: wallpaper,
            memCacheWidth: 800,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
