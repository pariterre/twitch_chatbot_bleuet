import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'twitch_models.dart';

class TwitchAuthentication {
  ///
  /// [oauthKey] is the OAUTH key. If none is provided, the process to generate
  /// one is launched.
  /// [streamerName] is the name of the channel to connect
  /// [moderatorName] is the name of the current logged in moderator. If it is
  /// left empty [streamerName] is used.
  /// [scope] is the required scope of the current app. Comes into play if
  /// generate OAUTH is launched.
  ///
  TwitchAuthentication({
    this.oauthKey,
    required this.streamerName,
    String? moderatorName,
    required this.appId,
    required this.scope,
  }) : moderatorName = moderatorName ?? streamerName;

  String? oauthKey;
  final String appId;
  final List<TwitchScope> scope;
  final String streamerName;
  final String moderatorName;

  ///
  /// Prepare everything which is required when connecting with Twitch API
  /// [requestUserToBrowse] provides a website that the user must navigate to in
  /// order to authenticate
  ///
  Future<void> connect({
    required Future<void> Function(String address) requestUserToBrowse,
  }) async {
    oauthKey ??= await _generateOauthKey(requestUserToBrowse);
    // TODO: Validate key every hour (https://dev.twitch.tv/docs/authentication/validate-tokens/)
  }

  ///
  /// Get a new OAUTH for the user
  ///
  Future<String> _generateOauthKey(
    Future<void> Function(String) requestUserToBrowse,
  ) async {
    String stateToken = Random().nextInt(0x7fffffff).toString();

    final address = 'https://id.twitch.tv/oauth2/authorize?'
        'response_type=token'
        '&client_id=$appId'
        '&redirect_uri=http://localhost:3000'
        '&scope=${scope.map<String>((e) => e.text()).join('+')}'
        '&state=$stateToken';
    requestUserToBrowse(address);

    // Wait for the user to navigate
    final response = await _waitForAuthentication();

    final re = RegExp(
        r'^http://localhost:3000/#access_token=([a-zA-Z0-9]*)&.*state=([0-9]*).*$');
    final match = re.firstMatch(response);

    if (match!.group(2)! != stateToken) {
      throw 'State token not equal, this connexion may be compromised';
    }
    return match.group(1)!;
  }

  Future<String> _waitForAuthentication() async {
    const postingKeyWebsite = '<!DOCTYPE html>'
        '<html><body>'
        'You can close this page'
        '<script>'
        'var xhr = new XMLHttpRequest();'
        'xhr.open("POST", \'http://localhost:3000\', true);'
        'xhr.setRequestHeader(\'Content-Type\', \'application/json\');'
        'xhr.send(JSON.stringify({\'token\': window.location.href}));'
        '</script>'
        '</body></html>';

    bool hasRequestedWebsite = false;
    bool hasSentKey = false;
    String answer = '';

    void waitingForAnswer(Socket client) {
      // The first answer is to post the validation key
      if (!hasRequestedWebsite) {
        client.listen((data) async {
          hasRequestedWebsite = true;
          client.write('HTTP/1.1 200 OK\nContent-Type: text\n'
              'Content-Length: ${postingKeyWebsite.length}\n'
              '\n'
              '$postingKeyWebsite');
          client.close();
          return;
        });
      } else {
        client.listen((data) async {
          client.close();

          final answerAsString = String.fromCharCodes(data).trim();
          answer = jsonDecode(answerAsString.split('\n').last)['token']!;
          hasSentKey = true;
          return;
        });
      }
    }

    final server = await ServerSocket.bind('localhost', 3000);
    server.listen(waitingForAnswer);
    while (!hasSentKey) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return answer;
  }
}
