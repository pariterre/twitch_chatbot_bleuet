import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'sceens/twitch_chat_bot.dart';
import 'twitch_models/twitch_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: TwitchChatBot(twitchManager: await _getTwitchManager()),
  ));
}

Future<TwitchManager> _getTwitchManager() async {
// Twitch app informations
  const credentialsPath = 'credentials.json';
  const appId = 'mcysoxq3vitdjwcqn71f8opz11cyex';
  final scope = [
    TwitchScope.chatRead,
    TwitchScope.chatEdit,
    TwitchScope.readFollowers,
    TwitchScope.readSubscribers,
  ];

  late String oauth;
  if (!await File(credentialsPath).exists()) {
    oauth =
        await TwitchAuthenticator.generateOauthKey(appId: appId, scope: scope);

    final file = File(credentialsPath);
    await file.writeAsString(json.encode({'oauthKey': oauth}));
  } else {
    oauth = jsonDecode(File(credentialsPath).readAsStringSync())['oauthKey'];
  }

  final authenticator = TwitchAuthenticator(oauthKey: oauth, appId: appId);

  return await TwitchManager.factory(
      authenticator: authenticator,
      ircCredentials:
          TwitchIrcCredentials(username: 'BotBleuet', channel: 'pariterre'));
}
