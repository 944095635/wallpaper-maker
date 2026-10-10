import 'cdp_service.dart';

class NeteaseBgService {
  final CdpService _cdp;

  NeteaseBgService({int port = 8686}) : _cdp = CdpService(port: port);

  /// 连接到网易云音乐
  Future<bool> connect() async {
    return _cdp.connectToFirstPage();
  }

  /// 获取可调试页面列表
  Future<List<CdpPage>> getPages() async {
    return _cdp.getPages();
  }

  /// 设置背景图片（持久化，刷新后仍生效）
  Future<int?> setBackgroundImage(String imageUrl) async {
    final css = _buildBackgroundCss(imageUrl);
    return _cdp.injectCssOnLoad(css);
  }

  /// 设置背景颜色（持久化）
  Future<int?> setBackgroundColor(String color) async {
    final css = _buildBackgroundCss(color, isColor: true);
    return _cdp.injectCssOnLoad(css);
  }

  /// 立即应用背景（一次性，刷新后失效）
  Future<dynamic> applyBackgroundNow(String imageUrl) async {
    final js =
        '''
      (function() {
        var style = document.createElement('style');
        style.textContent = ${_encodeJs(_buildBackgroundCss(imageUrl))};
        document.head.appendChild(style);
      })();
    ''';
    return _cdp.evaluateJs(js);
  }

  /// 构建网易云音乐背景 CSS
  String _buildBackgroundCss(String value, {bool isColor = false}) {
    final bgValue = isColor ? value : 'url("$value") center/cover no-repeat';

    return '''
      /* 全局背景 */
      body {
        background: $bgValue !important;
        background-attachment: fixed !important;
      }

      /* 透明化各层容器，让背景透出来 */
      .g-wrap,
      .g-main,
      .g-mn,
      .g-mn2,
      .g-sd,
      .g-sd1,
      .g-sd2,
      .n-songtbl,
      .m-playlist,
      .m-info,
      .m-info-wrap,
      .g-bd,
      .g-bd1,
      .g-bd2,
      .j-flag,
      .m-lyric,
      .m-lyric-wrap,
      .n-songtb,
      .u-cover,
      .m-info,
      .m-info-cover,
      .g-play,
      .g-play-jfr,
      .m-player,
      .m-player-wrap,
      .m-pinfo,
      .m-pbar,
      .m-playlist,
      .m-playlist-wrap,
      .g-slg,
      .g-slg-bd,
      .m-nav,
      .m-nav-wrap,
      .m-subnav,
      .m-subnav-wrap,
      .m-fm,
      .m-fm-wrap,
      .m-fm-info,
      .m-fm-play,
      .m-fm-btns,
      .m-fm-state,
      .m-fm-state-wrap,
      .m-fm-state-bg,
      .m-fm-state-info,
      .m-fm-state-info-wrap,
      .m-fm-state-info-name,
      .m-fm-state-info-artist,
      .m-fm-state-info-album,
      .m-fm-state-info-like,
      .m-fm-state-info-trash,
      .m-fm-state-info-next,
      .m-fm-state-info-play,
      .m-fm-state-info-pause,
      .m-fm-state-info-progress,
      .m-fm-state-info-progress-wrap,
      .m-fm-state-info-progress-bar,
      .m-fm-state-info-progress-bar-wrap {
        background: transparent !important;
        background-image: none !important;
        background-color: transparent !important;
      }

      /* 侧边栏半透明 */
      .g-sd, .g-sd1, .g-sd2 {
        background: rgba(0, 0, 0, 0.2) !important;
      }

      /* 主内容区半透明 */
      .g-mn, .g-mn2 {
        background: rgba(0, 0, 0, 0.1) !important;
      }

      /* 底部播放栏半透明 */
      .g-play, .m-player {
        background: rgba(0, 0, 0, 0.3) !important;
      }
    ''';
  }

  /// 执行 JS 表达式（一次性，刷新后失效）
  Future<dynamic> evaluateJs(String expression) async {
    return _cdp.evaluateJs(expression);
  }

  /// 移除注入的脚本
  Future<void> removeInjectedScript(int identifier) async {
    await _cdp.removeInjectedScript(identifier);
  }

  /// 断开连接
  void disconnect() {
    _cdp.disconnect();
  }

  /// 释放资源
  void dispose() {
    _cdp.dispose();
  }

  String _encodeJs(String value) {
    return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';
  }
}
