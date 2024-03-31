import 'package:flutter/material.dart';
import 'package:twitch_chat_bot/managers/configuration_manager.dart';
import 'package:twitch_chat_bot/models/command_controller.dart';

class TwitchCommandFormField extends StatefulWidget {
  const TwitchCommandFormField({
    super.key,
    required this.controller,
    required this.hintCommand,
    required this.hintAnswer,
    required this.onDelete,
  });

  final CommandController controller;
  final String hintCommand;
  final String hintAnswer;
  final void Function() onDelete;

  @override
  State<TwitchCommandFormField> createState() => _TwitchCommandFormFieldState();
}

class _TwitchCommandFormFieldState extends State<TwitchCommandFormField> {
  Widget _buildStartButton() {
    if (widget.controller.isActive) {
      return IconButton(
          onPressed: () => setState(() => widget.controller.isActive = false),
          icon: Icon(Icons.pause,
              color: ConfigurationManager.instance.twitchColorDark));
    } else {
      return IconButton(
          onPressed: () => setState(() => widget.controller.isActive = true),
          icon: Icon(Icons.send,
              color: ConfigurationManager.instance.twitchColorDark));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                minLines: 1,
                maxLines: 1,
                initialValue: widget.controller.command,
                enabled: true,
                onChanged: (value) =>
                    setState(() => widget.controller.command = value),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.hintCommand),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                maxLength: 500,
                minLines: 1,
                maxLines: null,
                initialValue: widget.controller.answer,
                enabled: true,
                onChanged: (value) =>
                    setState(() => widget.controller.answer = value),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.hintAnswer),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: _buildStartButton(),
            ),
          ],
        ),
      ],
    );
  }
}
