import 'twitch_models.dart';

class TwitchManager {
  late final TwitchAuthenticator _authenticator;
  late final TwitchIrc? irc;
  late final TwitchApi api;

  ///
  /// Main constructor
  /// [streamerName] is the name of the stream. [moderatorName] is the current
  /// logged id used with authenticator. If it is left empty, [streamerName]
  /// is used
  ///
  static Future<TwitchManager> factory({
    required TwitchAuthenticator authenticator,
    required TwitchCredentials credentials,
  }) async {
    final irc =
        await TwitchIrc.factory(credentials, authenticator: authenticator);

    final api = await TwitchApi.factory(
      credentials,
      authenticator: authenticator,
    );

    return TwitchManager._(authenticator, irc, api);
  }

  ///
  /// Private constructor
  ///
  TwitchManager._(this._authenticator, this.irc, this.api);
}
