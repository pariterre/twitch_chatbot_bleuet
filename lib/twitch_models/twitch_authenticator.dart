import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'twitch_models.dart';

class TwitchAuthenticator {
  final String oauthKey;
  final String appId;

  TwitchAuthenticator({
    required this.oauthKey,
    required this.appId,
  });

  // TODO: Validate key every hour (https://dev.twitch.tv/docs/authentication/validate-tokens/)

  ///
  /// Get a new OAUTH for the user
  ///
  static Future<String> generateOauthKey({
    required String appId,
    required List<TwitchScope> scope,
    Future<String> Function(String)? authenticateCallback,
  }) async {
    String stateToken = Random().nextInt(0x7fffffff).toString();

    final address = 'https://id.twitch.tv/oauth2/authorize?'
        'response_type=token'
        '&client_id=$appId'
        '&redirect_uri=http://localhost:3000'
        '&scope=${scope.map<String>((e) => e.text()).join('+')}'
        '&state=$stateToken';
    final answer = authenticateCallback != null
        ? await authenticateCallback(address)
        : await _authenticateViaConsole(address);

    final re =
        RegExp(r'^http://localhost:3000/#access_token=([a-zA-Z0-9]*)&.*$');
    final match = re.firstMatch(answer);

    return match!.group(1)!;
  }

  static Future<String> _authenticateViaConsole(String address) async {
    stdout.write('Please navigate to the following address:\n$address\n');

    const postingKeyWebsite = '<!DOCTYPE html>'
        '<html><body>'
        'Redirecting you... Please wait!'
        '<script>'
        'var xhr = new XMLHttpRequest();'
        'xhr.open("POST", \'http://localhost:3000\', true);'
        'xhr.setRequestHeader(\'Content-Type\', \'application/json\');'
        'xhr.send(JSON.stringify({\'token\': window.location.href}));'
        '</script>'
        '</body></html>';

    const canCloseWebsite = '<!DOCTYPE html>'
        '<html><body>'
        'You can close this page'
        '</body></html>';

    bool hasRequestedWebsite = false;
    bool hasSentKey = false;
    String answer = '';

    void waitingForAnswer(Socket client) {
      // The first answer is to post the validation key
      if (!hasRequestedWebsite) {
        client.listen((data) async {
          hasRequestedWebsite = true;
          client.write(
              "HTTP/1.1 200 OK\nContent-Type: text\nContent-Length: ${postingKeyWebsite.length}\n\n$postingKeyWebsite");
          client.close();
          return;
        });
      } else {
        client.listen((data) async {
          client.write(
              "HTTP/1.1 200 OK\nContent-Type: text\nContent-Length: ${canCloseWebsite.length}\n\n$canCloseWebsite");
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
