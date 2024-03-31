import 'package:twitch_chat_bot/managers/twitch_manager.dart';

class InstantMessageController {
  InstantMessageController();

  String message = '';
  bool get isReadyToSend => TwitchManager.isConnected && message != '';

  void sendText() => TwitchManager.instance?.chat.send(message);
}
