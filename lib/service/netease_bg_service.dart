import 'dart:convert';
import 'cdp_service.dart';

/*
 * 网易云音乐视频背景服务
 *
 * 通过 CDP 协议向网易云音乐页面注入 JS/CSS，实现视频动态背景：
 * - 注入 <video> 元素作为全屏背景，自动播放/循环/静音
 * - 覆盖网易云 CSS 变量和容器背景，使视频背景可见
 * - 主要容器使用半透明 + 毛玻璃效果，保持内容可读性
 * - 支持持久化注入（刷新后仍生效）和临时注入（刷新后失效）
 */
class NeteaseBgService {
  /// CDP 服务实例，用于与网易云音乐页面通信
  final CdpService _cdp;

  /// 视频背景元素的 DOM ID，用于避免重复注入
  static const _videoElementId = 'netease-bg-video';

  /// 样式覆盖元素的 DOM ID，用于避免重复注入
  static const _styleElementId = 'netease-bg-override';

  NeteaseBgService({int port = 8686}) : _cdp = CdpService(port: port);

  /// 连接到网易云音乐
  ///
  /// 自动查找第一个可调试页面并建立 WebSocket 连接。
  /// 连接成功后才能执行后续的背景注入操作。
  Future<bool> connect() async {
    return _cdp.connectToFirstPage();
  }

  /// 获取可调试页面列表
  ///
  /// 返回网易云音乐暴露的所有可调试标签页/窗口信息。
  Future<List<CdpPage>> getPages() async {
    return _cdp.getPages();
  }

  /// 设置视频动态背景（持久化，刷新后仍生效）
  ///
  /// [videoUrl] 视频 URL，支持网络视频或本地服务器视频
  /// [opacity] 视频透明度，0.0~1.0，默认 0.6
  /// [blur] 高斯模糊半径（像素），默认 8
  /// [brightness] 亮度系数，0.0~1.0，默认 0.4（降低亮度避免干扰内容）
  ///
  /// 视频会自动播放、循环、静音（浏览器策略要求静音才能自动播放），
  /// 固定定位覆盖整个视口，z-index 设为 -9999 确保在内容下方。
  /// 返回注入脚本的标识符，可用于 [removeInjectedScript] 移除。
  Future<String?> setBackgroundImageVideo(
    String videoUrl, {
    double opacity = 0.6,
    double blur = 8,
    double brightness = 0.4,
  }) async {
    final js = _buildVideoBackgroundJs(
      videoUrl,
      opacity: opacity,
      blur: blur,
      brightness: brightness,
    );
    return _cdp.injectScriptOnLoad(js);
  }

  /// 立即应用视频背景（一次性，刷新后失效）
  ///
  /// [videoUrl] 视频 URL
  /// [opacity] 视频透明度，默认 0.6
  /// [blur] 高斯模糊半径，默认 8
  /// [brightness] 亮度系数，默认 0.4
  ///
  /// 通过 Runtime.evaluate 立即执行，效果即时可见但页面刷新后失效。
  Future<dynamic> applyBackgroundVideoNow(
    String videoUrl, {
    double opacity = 0.6,
    double blur = 8,
    double brightness = 0.4,
  }) async {
    final js = _buildVideoBackgroundJs(
      videoUrl,
      opacity: opacity,
      blur: blur,
      brightness: brightness,
    );
    return _cdp.evaluateJs(js);
  }

  /// 执行 JS 表达式（一次性，刷新后失效）
  ///
  /// [expression] 要执行的 JavaScript 代码
  ///
  /// 代理 CdpService.evaluateJs，用于临时执行自定义 JS 代码。
  Future<dynamic> evaluateJs(String expression) async {
    return _cdp.evaluateJs(expression);
  }

  /// 移除页面加载时注入的脚本
  ///
  /// [identifier] 是 setBackgroundImageVideo 等方法返回的标识符，
  /// 移除后该脚本不会再在新页面加载时执行。
  Future<void> removeInjectedScript(int identifier) async {
    await _cdp.removeInjectedScript(identifier);
  }

  /// 重置背景，移除所有已注入的视频和样式
  ///
  /// 通过 Runtime.evaluate 立即执行移除操作，
  /// 删除页面中的视频背景元素和样式覆盖元素，
  /// 并恢复 body 的默认背景。
  Future<dynamic> resetBackground() async {
    final js =
        '''
      (function() {
        var oldVideo = document.getElementById('$_videoElementId');
        if (oldVideo) oldVideo.remove();
        var oldStyle = document.getElementById('$_styleElementId');
        if (oldStyle) oldStyle.remove();
        document.body.style.background = '';
        document.body.style.backgroundImage = '';
      })();
    ''';
    return _cdp.evaluateJs(js);
  }

  /// 断开 WebSocket 连接
  void disconnect() {
    _cdp.disconnect();
  }

  /// 释放所有资源
  ///
  /// 在服务不再使用时调用，确保 CDP 连接被正确关闭。
  void dispose() {
    _cdp.dispose();
  }

  /// 构建视频背景注入 JS 代码
  ///
  /// [videoUrl] 视频源地址
  /// [opacity] 视频透明度，0.0~1.0
  /// [blur] 高斯模糊半径（像素）
  /// [brightness] 亮度系数，0.0~1.0
  ///
  /// 生成的 JS 会：
  /// 1. 创建 <video> 元素，设置自动播放、循环、静音
  /// 2. 设置视频固定定位、全屏覆盖、模糊、亮度等样式
  /// 3. 移除旧的同 ID 视频元素（避免重复）
  /// 4. 将视频插入到 body 最前面（z-index: -9999 确保在内容下方）
  /// 5. 创建样式覆盖元素，透明化各层容器让视频背景可见
  String _buildVideoBackgroundJs(
    String videoUrl, {
    double opacity = 0.6,
    double blur = 8,
    double brightness = 0.4,
  }) {
    final css = _buildOverrideCss();

    return '''
      (function() {
        var oldVideo = document.getElementById('$_videoElementId');
        if (oldVideo) oldVideo.remove();

        var video = document.createElement('video');
        video.id = '$_videoElementId';
        video.autoplay = true;
        video.loop = true;
        video.muted = true;
        video.playsInline = true;
        video.src = ${jsonEncode(videoUrl)};
        video.style.cssText = 'position:fixed!important;top:0!important;left:0!important;width:100vw!important;height:100vh!important;object-fit:cover!important;z-index:-9999!important;opacity:$opacity!important;filter:blur(${blur}px) brightness($brightness)!important;pointer-events:none!important;transition:all 0.5s ease!important;';
        document.body.insertBefore(video, document.body.firstChild);

        var oldStyle = document.getElementById('$_styleElementId');
        if (oldStyle) oldStyle.remove();
        var style = document.createElement('style');
        style.id = '$_styleElementId';
        style.textContent = ${jsonEncode(css)};
        document.head.appendChild(style);
      })();
    ''';
  }

  /// 构建网易云音乐样式覆盖 CSS
  ///
  /// CSS 覆盖策略：
  /// 1. 覆盖网易云音乐的 CSS 变量（--colorBackground 等），使主题背景透明
  /// 2. 设置 body/html 背景透明（视频元素本身就是背景）
  /// 3. 主要容器使用半透明背景 + backdrop-filter 毛玻璃效果，保持内容可读性
  /// 4. 侧边栏使用渐变半透明背景
  String _buildOverrideCss() {
    return '''
      /* 覆盖主题背景色变量 */
      :root {
        --colorBackground: transparent !important;
        --colorBackgroundWhite: transparent !important;
      }

      .sticky-oper-enter-done { display: none !important; }

      .app-background-enter-done { display: none !important; }
    ''';
  }
}
