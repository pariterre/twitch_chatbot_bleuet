import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart' as tm;

class ConfigurationManager {
  static ConfigurationManager get instance => _singleton;

  final useTwitchMock = false;

  final twitchAppInfo = tm.TwitchAppInfo(
    appName: 'Chatbot Bleuet',
    twitchAppId: '9hlzml6vu97qqghxubqe51i3l4d0y1',
    redirectUri: 'twitchauthentication.pariterre.net',
    // Requested scopes for the connexion
    scope: const [
      tm.TwitchScope.chatRead,
      tm.TwitchScope.chatEdit,
      tm.TwitchScope.chatters,
    ],
  );

  final twitchDebugOptions = tm.TwitchDebugPanelOptions(
    // Which chatters are currently in the chat
    chatters: [
      tm.TwitchChatterMock(displayName: 'Streamer', isStreamer: true),
      tm.TwitchChatterMock(displayName: 'Moderator', isModerator: true),
      tm.TwitchChatterMock(displayName: 'Follower'),
      tm.TwitchChatterMock(displayName: 'Viewer', isFollower: false),
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
