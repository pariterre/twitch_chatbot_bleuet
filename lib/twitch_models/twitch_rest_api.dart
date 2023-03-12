import 'package:http/http.dart';

import 'twitch_models.dart';

class TwitchRestApi {
  TwitchRestApi({required this.authenticator});

  final TwitchAuthenticator authenticator;

  ///
  /// Get the ID for the [username].
  ///
  Future<String> getStreamerId(String username) async {
    // TODO This does not work
    final answer = await post(
      Uri.parse('https://api.twitch.tv/helix/users?login=$username'),
      headers: <String, String>{
        'Authorization': 'Bearer ${authenticator.oauthKey}',
        'Client-Id': authenticator.appId,
      },
    );

    //log(answer.body);
    return answer.body;
  }
}
