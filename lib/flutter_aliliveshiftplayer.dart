import 'package:flutter_aliplayer/flutter_aliplayer.dart';

class FlutterAliLiveShiftPlayer extends FlutterAliplayer {
  @override
  // ignore: overridden_fields
  String playerId = 'liveShiftPlayerDefault';

  FlutterAliLiveShiftPlayer.init(String? id) : super.init(id);

  @override

  /// 创建直播时移播放器
  Future<void> create() async {
    mState = FlutterAvpdef.initalized;
    fireEvent("onStateChanged", {"newState": mState});
  }

  /// 直播时移，获取直播时间
  Future<dynamic> getCurrentLiveTime() async {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 直播时移，获取当前播放时间
  Future<dynamic> getCurrentTime() async {
    return mCurrentPosition;
  }

  /// 直播时移，跳转到指定时移位置
  Future<void> seekToLiveTime(int liveTime) async {
    mCurrentPosition = liveTime;
  }

  /// 直播时移，设置直播时移地址
  Future<void> setDataSource(String timeLineUrl, String url,
      {String? coverPath, String? format, String? title}) async {
    // Mock DataSource setting
  }
}
