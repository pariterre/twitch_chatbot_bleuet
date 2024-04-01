import 'package:twitch_chatbot_bleuet/managers/twitch_manager.dart';

class InstantMessageController {
  InstantMessageController();

  String message = '';
  bool get isReadyToSend => TwitchManager.isConnected && message != '';

  void sendText() => TwitchManager.instance?.chat.send(message);
}
