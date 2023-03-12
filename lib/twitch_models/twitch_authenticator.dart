import 'dart:async';
import 'dart:developer' as dev;
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

  // TODO: Validate key every hour

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
        : _authenticateViaConsole(address);

    final re =
        RegExp(r'^http://localhost:3000/#access_token=([a-zA-Z0-9]*)&.*$');
    final match = re.firstMatch(answer);

    return match!.group(1)!;
  }

  static String _authenticateViaConsole(String address) {
    dev.log('Please navigate to the following address, then copy the '
        'answer here:\n$address');

    return stdin.readLineSync()!;
  }
}
