import 'package:botbleuet_twitch/sceens/twitch_authentication_screen.dart';
import 'package:flutter/material.dart';

import 'sceens/twitch_chat_bot.dart';

void main() async {
  runApp(MaterialApp(
    initialRoute: TwitchAuthenticationScreen.route,
    routes: {
      TwitchAuthenticationScreen.route: (ctx) =>
          const TwitchAuthenticationScreen(nextRoute: TwitchChatBot.route),
      TwitchChatBot.route: (ctx) => const TwitchChatBot(),
    },
  ));
}
