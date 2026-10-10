import 'dart:async';
import 'dart:convert';
import 'dart:io';

/*
 * Chrome DevTools Protocol (CDP) 服务
 *
 * 通过 Chromium 的 --remote-debugging-port 参数开启的调试端口，
 * 使用 HTTP 获取页面列表，使用 WebSocket 发送 CDP 命令来控制页面。
 *
 * 典型流程：
 * 1. getPages()        → 通过 HTTP 获取所有可调试页面
 * 2. connect(wsUrl)    → 通过 WebSocket 连接到目标页面
 * 3. sendCommand()     → 发送 CDP 命令（如注入 JS、执行表达式等）
 */
class CdpService {
  /// 调试端口号，对应 --remote-debugging-port 启动参数
  final int port;

  CdpService({this.port = 8686});

  /// HTTP 客户端，用于请求调试端口的 HTTP 接口（如 /json 获取页面列表）
  HttpClient? _httpClient;

  /// WebSocket 连接，用于与目标页面建立 CDP 双向通信通道
  WebSocket? _webSocket;

  /// CDP 消息自增 ID，每条发送的命令都需要唯一 ID 来匹配响应
  int _messageId = 0;

  /// 调试端口的 HTTP 地址，用于获取页面列表等 REST 接口
  String get _httpUrl => 'http://localhost:$port';

  /// 调试端口的 WebSocket 地址前缀，用于拼接完整的 WebSocket 调试 URL
  // String get _wsUrl => 'ws://localhost:$port';

  /// 懒加载的 HTTP 客户端实例，避免重复创建
  Future<HttpClient> get _client async {
    _httpClient ??= HttpClient();
    return _httpClient!;
  }

  /// 获取所有可调试的页面列表
  ///
  /// 请求 http://localhost:{port}/json 接口，
  /// 返回 Chromium 暴露的所有可调试标签页/窗口信息，
  /// 包含页面 ID、标题、URL、WebSocket 调试地址等。
  Future<List<CdpPage>> getPages() async {
    final client = await _client;
    final request = await client.getUrl(Uri.parse('$_httpUrl/json'));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final List jsonList = jsonDecode(body);
    return jsonList.map((e) => CdpPage.fromJson(e)).toList();
  }

  /// 获取第一个页面的 WebSocket 调试 URL
  ///
  /// 从页面列表中取第一个页面的 [CdpPage.webSocketDebuggerUrl]，
  /// 用于后续通过 WebSocket 建立 CDP 通信。如果没有页面则返回 null。
  Future<String?> getFirstPageWsUrl() async {
    final pages = await getPages();
    if (pages.isEmpty) return null;
    return pages.first.webSocketDebuggerUrl;
  }

  /// 连接到指定页面的 WebSocket 通道
  ///
  /// [wsUrl] 是从 [CdpPage.webSocketDebuggerUrl] 获取的完整 WebSocket 地址，
  /// 连接成功后即可通过 [sendCommand] 发送 CDP 命令控制该页面。
  /// 返回是否连接成功。
  Future<bool> connect(String wsUrl) async {
    try {
      _webSocket = await WebSocket.connect(wsUrl);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 自动连接到第一个可调试页面
  ///
  /// 等价于 getPages() → 取第一个 → connect(wsUrl) 的快捷方式。
  /// 适用于只有一个目标页面的场景（如网易云音乐主窗口）。
  Future<bool> connectToFirstPage() async {
    final wsUrl = await getFirstPageWsUrl();
    if (wsUrl == null) return false;
    return connect(wsUrl);
  }

  /// 发送 CDP 命令并等待对应 ID 的响应
  ///
  /// [method] CDP 方法名，如 'Runtime.evaluate'、'Page.addScriptToEvaluateOnNewDocument'
  /// [params] 方法参数，不同方法有不同的参数结构
  ///
  /// CDP 协议采用请求-响应模式，每条命令带唯一 [id]，
  /// 通过监听 WebSocket 消息流，匹配相同 id 的响应来返回结果。
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

  /// 在页面中执行 JS 表达式（一次性，页面刷新后失效）
  ///
  /// [expression] 要执行的 JavaScript 代码字符串
  ///
  /// 底层调用 CDP 的 Runtime.evaluate 方法，
  /// 适合临时执行一些 JS 代码，如获取页面信息、即时修改样式等。
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

  /// 注入 JS 脚本，每次页面加载时自动执行（刷新后仍生效）
  ///
  /// [script] 要注入的 JavaScript 代码
  ///
  /// 底层调用 CDP 的 Page.addScriptToEvaluateOnNewDocument 方法，
  /// 注入的脚本会在每次文档加载时自动执行，即使页面刷新或路由跳转也持续有效。
  /// 返回注入脚本的标识符 [identifier]，可用于 [removeInjectedScript] 移除。
  Future<String?> injectScriptOnLoad(String script) async {
    final result = await sendCommand(
      'Page.addScriptToEvaluateOnNewDocument',
      params: {'source': script},
    );

    return result['result']?['identifier'];
  }

  /// 移除页面加载时注入的脚本
  ///
  /// [identifier] 是 [injectScriptOnLoad] 返回的脚本标识符，
  /// 移除后该脚本不会再在新页面加载时执行。
  Future<void> removeInjectedScript(int identifier) async {
    await sendCommand(
      'Page.removeScriptToEvaluateOnNewDocument',
      params: {'identifier': identifier},
    );
  }

  /// 注入 CSS 样式（持久化，刷新后仍生效）
  ///
  /// [css] 要注入的 CSS 样式文本
  ///
  /// 原理：将 CSS 包装成创建 <style> 标签的 JS 代码，
  /// 再通过 [injectScriptOnLoad] 注入，实现每次页面加载时自动应用样式。
  Future<String?> injectCssOnLoad(String css) async {
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

  /// 断开 WebSocket 连接，释放通信通道
  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
  }

  /// 释放所有资源，包括 WebSocket 连接和 HTTP 客户端
  ///
  /// 在服务不再使用时调用，确保连接和客户端都被正确关闭，避免资源泄漏。
  void dispose() {
    disconnect();
    _httpClient?.close();
    _httpClient = null;
  }
}

/*
 * CDP 可调试页面信息
 *
 * 对应 http://localhost:{port}/json 接口返回的每个页面对象，
 * 包含页面的基本信息和 WebSocket 调试地址。
 */
class CdpPage {
  /// 页面唯一标识符，由 Chromium 内部分配
  final String id;

  /// 页面标题，即浏览器标签页上显示的标题
  final String title;

  /// 页面 URL，当前加载的网页地址
  final String url;

  /// WebSocket 调试地址，连接后可通过 CDP 协议控制该页面
  /// 格式如：ws://localhost:8686/devtools/page/xxxxx
  final String webSocketDebuggerUrl;

  CdpPage({
    required this.id,
    required this.title,
    required this.url,
    required this.webSocketDebuggerUrl,
  });

  /// 从 /json 接口返回的 JSON 对象构造实例
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
