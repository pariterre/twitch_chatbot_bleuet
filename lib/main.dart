import 'package:flutter/material.dart';
import 'package:twitch_chat_bot/managers/configuration_manager.dart';
import 'package:twitch_chat_bot/screens/chat_bot_screen.dart';

void main() async {
  runApp(MaterialApp(
    home: const TwitchChatBotScreen(),
    theme: ThemeData(
        dividerTheme: DividerThemeData(
            color: ConfigurationManager.instance.twitchColorLight),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: ConfigurationManager.instance.twitchColorDark,
                foregroundColor: Colors.white))),
  ));
}
