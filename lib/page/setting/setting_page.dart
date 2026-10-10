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
    text: 'https://picsum.photos/1920/1080',
  );

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
                onPressed: _isConnected ? _applyBackgroundPersist : null,
                child: Text('应用背景(持久)'),
              ),
              FilledButton(
                onPressed: _isConnected ? _applyBackgroundOnce : null,
                child: Text('应用背景(临时)'),
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
      ['--remote-debugging-port=$port'],
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

  /// 应用背景（持久化，刷新后仍生效）
  Future<void> _applyBackgroundPersist() async {
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) return;

    _updateStatus('正在注入持久背景...');

    try {
      _injectedScriptId = await _bgService.setBackgroundImage(imageUrl);
      _updateStatus('持久背景已注入 (id: $_injectedScriptId)，刷新页面仍有效');
    } catch (e) {
      _updateStatus('注入失败: $e');
    }
  }

  /// 应用背景（临时，刷新后失效）
  Future<void> _applyBackgroundOnce() async {
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) return;

    _updateStatus('正在注入临时背景...');

    try {
      await _bgService.applyBackgroundNow(imageUrl);
      _updateStatus('临时背景已应用，刷新页面后失效');
    } catch (e) {
      _updateStatus('注入失败: $e');
    }
  }

  /// 重置背景
  Future<void> _resetBackground() async {
    _updateStatus('正在重置...');

    try {
      if (_injectedScriptId != null) {
        await _bgService.removeInjectedScript(_injectedScriptId!);
        _injectedScriptId = null;
      }

      await _bgService.evaluateJs('''
        document.body.style.background = '';
        document.body.style.backgroundImage = '';
      ''');

      _updateStatus('背景已重置');
    } catch (e) {
      _updateStatus('重置失败: $e');
    }
  }

  /// 进入调试页面
  void _enterDebugPage() {
    final port = _portController.text.trim();
    Process.run('explorer', ['http://localhost:$port/']);
  }

  /// 更新状态
  void _updateStatus(String text) {
    setState(() {
      _statusText = text;
    });
  }
}
