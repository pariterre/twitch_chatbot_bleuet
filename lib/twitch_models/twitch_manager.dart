import 'twitch_models.dart';

class TwitchManager {
  late final TwitchAuthentication _authentication;
  late final TwitchIrc? irc;
  late final TwitchApi api;

  ///
  /// Main constructor
  /// [streamerName] is the name of the stream. [moderatorName] is the current
  /// logged id used with authenticator. If it is left empty, [streamerName]
  /// is used.
  /// [onAuthenticationRequest] is called if the Authentication needs to create a
  /// new OAUTH key. Adress is the address to browse.
  /// [onAuthenticationSuccess] This callback is called after the
  ///
  static Future<TwitchManager> factory({
    required TwitchAuthentication authentication,
    required Future<void> Function(String address) onAuthenticationRequest,
    required Future<void> Function(String key) onAuthenticationSuccess,
  }) async {
    await authentication.connect(requestUserToBrowse: onAuthenticationRequest);
    onAuthenticationSuccess(authentication.oauthKey!);

    final api = await TwitchApi.factory(authentication);
    final irc = await TwitchIrc.factory(authentication);

    return TwitchManager._(authentication, irc, api);
  }

  ///
  /// Private constructor
  ///
  TwitchManager._(this._authentication, this.irc, this.api);
}
