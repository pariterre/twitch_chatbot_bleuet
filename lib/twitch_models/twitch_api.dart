import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'twitch_models.dart';

class TwitchApi {
  TwitchApi({required this.authenticator});

  final TwitchAuthenticator authenticator;

  ///
  /// Get the ID for the [username].
  ///
  Future<int?> getStreamerId(String username) async {
    final response = await get(
      Uri.parse('https://api.twitch.tv/helix/users?login=$username'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer ${authenticator.oauthKey}',
        'Client-Id': authenticator.appId,
      },
    );

    final answer = jsonDecode(response.body)['data'] as List;
    if (answer.isEmpty) return null; // username not found

    return int.parse(answer[0]['id']);
  }
}
