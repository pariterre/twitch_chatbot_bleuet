import 'package:twitch_manager/twitch_manager.dart' as tm;

class TwitchManager {
  ///
  /// Check if the TwitchManager is connected
  static bool get isConnected => _singleton._manager?.isConnected ?? false;

  ///
  /// Setup a singleton for the TwitchManager
  static tm.TwitchManager? get instance => _singleton._manager;

  ///
  /// Initialize the singleton
  static void initialize(tm.TwitchManager manager) =>
      _singleton._manager = manager;

  ///
  /// Internal
  static final TwitchManager _singleton = TwitchManager._();
  TwitchManager._();
  tm.TwitchManager? _manager;
}
