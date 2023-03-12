import 'twitch_models.dart';

class TwitchManager {
  late final TwitchAuthenticator _authenticator;
  late final TwitchIrc? irc;
  late final TwitchApi api;

  ///
  /// Main constructor
  ///
  static Future<TwitchManager> factory({
    required TwitchAuthenticator authenticator,
    TwitchIrcCredentials? ircCredentials,
  }) async {
    final irc = ircCredentials != null
        ? await TwitchIrc.factory(ircCredentials, authenticator: authenticator)
        : null;

    final api = TwitchApi(authenticator: authenticator);

    return TwitchManager._(authenticator, irc, api);
  }

  ///
  /// Private constructor
  ///
  TwitchManager._(this._authenticator, this.irc, this.api);
}
