import 'package:twitch_manager/twitch_app.dart';

class TwitchManager {
  ///
  /// Check if the TwitchManager is connected
  static bool get isConnected => _singleton._manager?.isConnected ?? false;

  ///
  /// Setup a singleton for the TwitchManager
  static TwitchAppManager? get instance => _singleton._manager;

  ///
  /// Initialize the singleton
  static void initialize(TwitchAppManager manager) =>
      _singleton._manager = manager;

  ///
  /// Internal
  static final TwitchManager _singleton = TwitchManager._();
  TwitchManager._();
  TwitchAppManager? _manager;
}
