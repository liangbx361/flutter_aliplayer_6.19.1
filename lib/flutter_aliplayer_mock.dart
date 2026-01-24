import 'package:flutter_aliplayer/flutter_aliplayer.dart';

class FlutterAliplayerMock extends FlutterAliplayer {
  FlutterAliplayerMock.init(String? id) : super.init(id);

  // All logic is now in the base FlutterAliplayer class for pure Dart.
  // This class remains for backward compatibility in the plugin's own structure if needed.
}
