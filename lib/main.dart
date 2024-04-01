import 'package:flutter/material.dart';
import 'package:twitch_chatbot_bleuet/managers/configuration_manager.dart';
import 'package:twitch_chatbot_bleuet/screens/chat_bot_screen.dart';

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
