import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wallpaper_maker/service/netease_bg_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final NeteaseBgService _bgService = NeteaseBgService(port: 8686);

  bool _isConnected = false;
  String _statusText = '未连接';
  int? _injectedScriptId;

  final TextEditingController _portController = TextEditingController(
    text: '8686',
  );
  final TextEditingController _imageUrlController = TextEditingController(
    text: "https://down.haowallpaper.com/project_file/2025_07_25_file/17323846557748608.mp4?zfsign=1791615411-3d7b4044d8fddfbe-0-18aa95ccdc12322a047a5ce774f6f002",
    // text: 'https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/37989e59-411b-4dd0-9f0f-85720a04d5f3/transcode=true,original=true/Train_neon_graded.webm',
  );

  // 300KB https://img.haowallpaper.com/pre_cache_file/2025_07_25_file/17323846557748608.mp4
  //https://down.haowallpaper.com/project_file/2025_07_25_file/17323846557748608.mp4?zfsign=1791615411-3d7b4044d8fddfbe-0-18aa95ccdc12322a047a5ce774f6f002

  @override
  void dispose() {
    _bgService.dispose();
    _portController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('- 网易云音乐 -', style: TextStyle(fontSize: 20)),

          Text('网易云音乐需要在启动时开启调试功能，通过调试功能修改背景'),

          Text(
            '网易云安装路径：C:\\Program Files\\NetEase\\CloudMusic\\CloudMusic.exe',
          ),

          SizedBox(
            width: 200,
            child: TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: '端口号',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),

          Wrap(
            spacing: 10,
            children: [
              FilledButton(
                onPressed: _startNeteaseMusic,
                child: Text('启动网易云'),
              ),
              FilledButton(
                onPressed: _connectToNetease,
                child: Text('连接'),
              ),
              FilledButton(
                onPressed: _enterDebugPage,
                child: Text('调试页面'),
              ),
            ],
          ),

          Divider(),

          Text('- 背景设置 -', style: TextStyle(fontSize: 20)),

          Text('状态: $_statusText'),

          SizedBox(
            width: 400,
            child: TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: '背景图片 URL',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),

          Wrap(
            spacing: 10,
            children: [
              FilledButton(
                onPressed: _isConnected ? _applyBackgroundVideo : null,
                child: Text('应用视频背景'),
              ),

              FilledButton(
                onPressed: _isConnected ? _resetBackground : null,
                child: Text('重置背景'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 启动网易云音乐
  void _startNeteaseMusic() {
    final port = _portController.text.trim();
    Process.run(
      'C:\\Program Files\\NetEase\\CloudMusic\\CloudMusic.exe',
      [
        '--remote-debugging-port=$port',
        '--allow-file-access-from-files',
      ],
    );
    _updateStatus('已发送启动命令，等待几秒后点击"连接"');
  }

  /// 连接到网易云音乐
  Future<void> _connectToNetease() async {
    _updateStatus('正在连接...');

    try {
      final pages = await _bgService.getPages();
      if (pages.isEmpty) {
        _updateStatus('未找到可调试页面，请确认网易云已启动且端口正确');
        return;
      }

      final connected = await _bgService.connect();
      if (connected) {
        _isConnected = true;
        _updateStatus('已连接，发现 ${pages.length} 个页面');
      } else {
        _updateStatus('WebSocket 连接失败');
      }
    } catch (e) {
      _updateStatus('连接失败: $e');
    }
  }

  /// 重置背景
  Future<void> _resetBackground() async {
    _updateStatus('正在重置...');

    try {
      await _bgService.resetBackground();

      _updateStatus('背景已重置');
    } catch (e) {
      _updateStatus('重置失败: $e');
    }
  }

  /// 应用视频背景
  Future<void> _applyBackgroundVideo() async {
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) return;

    _updateStatus('正在注入视频背景...');

    try {
      await _bgService.applyBackgroundVideoNow(
        imageUrl,
        opacity: 1,
        blur: 0,
        brightness: 1,
      );
      _updateStatus('视频背景已应用，刷新页面后失效');
    } catch (e) {
      _updateStatus('注入失败: $e');
    }
  }

  /// 进入调试页面
  void _enterDebugPage() {
    final port = _portController.text.trim();
    Process.run('explorer', ['http://localhost:$port/']);
  }

  /// 更新状态
  void _updateStatus(String text) {
    debugPrint(text);
    setState(() {
      _statusText = text;
    });
  }
}
