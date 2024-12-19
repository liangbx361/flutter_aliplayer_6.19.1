import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';

class FlutterAliLiveShiftPlayer extends FlutterAliplayer {
  String playerId = 'liveShiftPlayerDefault';

  FlutterAliLiveShiftPlayer.init(String? id) : super.init(id);

  @override

  /// 创建直播时移播放器
  Future<void> create() {
    return FlutterAliPlayerFactory.methodChannel.invokeMethod('createAliPlayer',
        wrapWithPlayerId(arg: PlayerType.PlayerType_LiveShift));
  }

  /// 直播时移，获取直播时间
  Future<dynamic> getCurrentLiveTime() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getCurrentLiveTime', wrapWithPlayerId());
  }

  /// 直播时移，获取当前播放时间
  Future<dynamic> getCurrentTime() async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('getCurrentTime', wrapWithPlayerId());
  }

  /// 直播时移，跳转到指定时移位置
  Future<void> seekToLiveTime(int liveTime) async {
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('seekToLiveTime', wrapWithPlayerId(arg: liveTime));
  }

  /// 直播时移，设置直播时移地址
  Future<void> setDataSource(String timeLineUrl, String url,
      {String? coverPath, String? format, String? title}) async {
    Map<String, dynamic> dataSourceMap = {
      'timeLineUrl': timeLineUrl,
      'url': url,
      'coverPath': coverPath,
      'format': format,
      'title': title
    };
    return FlutterAliPlayerFactory.methodChannel
        .invokeMethod('setDataSource', wrapWithPlayerId(arg: dataSourceMap));
  }
}
