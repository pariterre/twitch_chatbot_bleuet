import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';

import '/sceens/twitch_authentication_screen.dart';
import '/sceens/twitch_chat_bot.dart';

void main() async {
  runApp(MaterialApp(
    initialRoute: TwitchAuthenticationScreen.route,
    routes: {
      TwitchAuthenticationScreen.route: (ctx) =>
          const TwitchAuthenticationScreen(
            nextRoute: TwitchChatBot.route,
            appId: 'mcysoxq3vitdjwcqn71f8opz11cyex',
            scope: [
              TwitchScope.chatRead,
              TwitchScope.chatEdit,
              TwitchScope.chatters,
              TwitchScope.readFollowers,
              TwitchScope.readSubscribers,
            ],
            moderatorName: 'BotBleuet',
            streamerName: 'pariterre',
          ),
      TwitchChatBot.route: (ctx) => const TwitchChatBot(),
    },
  ));
}
