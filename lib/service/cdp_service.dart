import 'dart:async';
import 'dart:convert';
import 'dart:io';

class CdpService {
  final int port;

  CdpService({this.port = 8686});

  HttpClient? _httpClient;
  WebSocket? _webSocket;
  int _messageId = 0;

  String get _httpUrl => 'http://localhost:$port';
  String get _wsUrl => 'ws://localhost:$port';

  Future<HttpClient> get _client async {
    _httpClient ??= HttpClient();
    return _httpClient!;
  }

  /// 获取所有可调试的页面列表
  Future<List<CdpPage>> getPages() async {
    final client = await _client;
    final request = await client.getUrl(Uri.parse('$_httpUrl/json'));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final List jsonList = jsonDecode(body);
    return jsonList.map((e) => CdpPage.fromJson(e)).toList();
  }

  /// 获取第一个页面的 WebSocket URL
  Future<String?> getFirstPageWsUrl() async {
    final pages = await getPages();
    if (pages.isEmpty) return null;
    return pages.first.webSocketDebuggerUrl;
  }

  /// 连接到指定页面的 WebSocket
  Future<bool> connect(String wsUrl) async {
    try {
      _webSocket = await WebSocket.connect(wsUrl);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 连接到第一个页面
  Future<bool> connectToFirstPage() async {
    final wsUrl = await getFirstPageWsUrl();
    if (wsUrl == null) return false;
    return connect(wsUrl);
  }

  /// 发送 CDP 命令并等待响应
  Future<Map<String, dynamic>> sendCommand(
    String method, {
    Map<String, dynamic>? params,
  }) async {
    if (_webSocket == null) {
      throw Exception('WebSocket 未连接');
    }

    final id = ++_messageId;
    final message = jsonEncode({
      'id': id,
      'method': method,
      'params': ?params,
    });

    final completer = Completer<Map<String, dynamic>>();

    StreamSubscription? subscription;
    subscription = _webSocket!.listen((data) {
      final json = jsonDecode(data) as Map<String, dynamic>;
      if (json['id'] == id) {
        subscription?.cancel();
        completer.complete(json);
      }
    });

    _webSocket!.add(message);
    return completer.future;
  }

  /// 执行 JS 表达式（一次性，刷新后失效）
  Future<dynamic> evaluateJs(String expression) async {
    final result = await sendCommand(
      'Runtime.evaluate',
      params: {
        'expression': expression,
        'returnByValue': true,
      },
    );

    final resultData = result['result']?['result'];
    return resultData?['value'];
  }

  /// 注入 JS，每次页面加载时自动执行（刷新后仍生效）
  Future<int?> injectScriptOnLoad(String script) async {
    final result = await sendCommand(
      'Page.addScriptToEvaluateOnNewDocument',
      params: {'source': script},
    );

    return result['result']?['identifier'];
  }

  /// 移除页面加载时注入的脚本
  Future<void> removeInjectedScript(int identifier) async {
    await sendCommand(
      'Page.removeScriptToEvaluateOnNewDocument',
      params: {'identifier': identifier},
    );
  }

  /// 注入 CSS 样式（持久化，刷新后仍生效）
  Future<int?> injectCssOnLoad(String css) async {
    final script =
        '''
      (function() {
        var style = document.createElement('style');
        style.textContent = ${jsonEncode(css)};
        document.head.appendChild(style);
      })();
    ''';
    return injectScriptOnLoad(script);
  }

  /// 断开连接
  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _httpClient?.close();
    _httpClient = null;
  }
}

/// CDP 页面信息
class CdpPage {
  final String id;
  final String title;
  final String url;
  final String webSocketDebuggerUrl;

  CdpPage({
    required this.id,
    required this.title,
    required this.url,
    required this.webSocketDebuggerUrl,
  });

  factory CdpPage.fromJson(Map<String, dynamic> json) {
    return CdpPage(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      webSocketDebuggerUrl: json['webSocketDebuggerUrl'] ?? '',
    );
  }

  @override
  String toString() => 'CdpPage(title: $title, url: $url)';
}
