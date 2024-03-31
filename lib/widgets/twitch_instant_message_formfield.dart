import 'package:flutter/material.dart';
import 'package:twitch_chat_bot/managers/configuration_manager.dart';
import 'package:twitch_chat_bot/models/instant_message_controller.dart';

class TwitchInstantMessageFormField extends StatefulWidget {
  const TwitchInstantMessageFormField(
      {super.key, required this.controller, required this.hint});

  final String hint;
  final InstantMessageController controller;

  @override
  State<TwitchInstantMessageFormField> createState() =>
      _TwitchInstantMessageFormFieldState();
}

class _TwitchInstantMessageFormFieldState
    extends State<TwitchInstantMessageFormField> {
  final _textController = TextEditingController();

  void _sendMessage() {
    widget.controller.sendText();
    widget.controller.message = '';
    _textController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            enabled: true,
            maxLength: 500,
            minLines: 1,
            maxLines: null,
            controller: _textController,
            onChanged: (value) =>
                setState(() => widget.controller.message = value),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
                border: const OutlineInputBorder(), labelText: widget.hint),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4),
          child: IconButton(
              onPressed: widget.controller.isReadyToSend ? _sendMessage : null,
              icon: Icon(Icons.send,
                  color: widget.controller.isReadyToSend
                      ? ConfigurationManager.instance.twitchColorDark
                      : Colors.grey)),
        ),
      ],
    );
  }
}
