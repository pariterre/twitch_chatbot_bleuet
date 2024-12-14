import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';

class ConfigurationManager {
  static ConfigurationManager get instance => _singleton;

  final useTwitchMock = false;

  final twitchAppInfo = TwitchAppInfo(
    appName: 'Chatbot Bleuet',
    twitchClientId: '9hlzml6vu97qqghxubqe51i3l4d0y1',
    twitchRedirectUri:
        Uri.https('twitchauthentication.pariterre.net', 'twitch_redirect.html'),
    authenticationServerUri:
        Uri.https('twitchserver.pariterre.net:3000', 'token'),
    // Requested scopes for the connexion
    scope: const [
      TwitchAppScope.chatRead,
      TwitchAppScope.chatEdit,
      TwitchAppScope.chatters,
    ],
  );

  final twitchDebugOptions = TwitchDebugPanelOptions(
    // Which chatters are currently in the chat
    chatters: [
      TwitchChatterMock(displayName: 'Streamer', isStreamer: true),
      TwitchChatterMock(displayName: 'Moderator', isModerator: true),
      TwitchChatterMock(displayName: 'Follower'),
      TwitchChatterMock(displayName: 'Viewer', isFollower: false),
    ],
    // Prewritten message to send to the chat
    chatMessages: [
      'Hello World!',
      'This is a test message',
      'This is a test message 2',
    ],
  );

  final twitchColorDark = const Color(0xFF6441a5);
  final twitchColorLight = const Color(0xFFb9a3e3);

  // Declare the singleton
  static final ConfigurationManager _singleton = ConfigurationManager._();
  ConfigurationManager._();
}
