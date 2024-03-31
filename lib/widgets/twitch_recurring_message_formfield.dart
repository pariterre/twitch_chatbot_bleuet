import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twitch_chat_bot/managers/configuration_manager.dart';
import 'package:twitch_chat_bot/models/recurring_message_controller.dart';

class TwitchRecurringMessageFormField extends StatefulWidget {
  const TwitchRecurringMessageFormField(
      {super.key,
      required this.controller,
      required this.hint,
      required this.onDelete});

  final ReccurringMessageController controller;
  final String hint;
  final void Function() onDelete;

  @override
  State<TwitchRecurringMessageFormField> createState() =>
      _TwitchRecurringMessageFormFieldState();
}

class _TwitchRecurringMessageFormFieldState
    extends State<TwitchRecurringMessageFormField> {
  void _setInterval(String value) {
    int? time = int.tryParse(value);
    widget.controller.interval =
        time == null ? Duration.zero : Duration(minutes: time);
    setState(() {});
  }

  void _setDelay(String value) {
    int? time = int.tryParse(value);
    widget.controller.delay =
        time == null ? Duration.zero : Duration(minutes: time);
  }

  Widget _buildStartButton() {
    if (widget.controller.isStarted) {
      return IconButton(
          onPressed: () =>
              setState(() => widget.controller.stopStreamingText()),
          icon: Icon(Icons.pause,
              color: ConfigurationManager.instance.twitchColorDark));
    } else {
      return IconButton(
          onPressed: widget.controller.isReadyToSend
              ? () => setState(() => widget.controller.startStreamingText())
              : null,
          icon: Icon(Icons.send,
              color: widget.controller.isReadyToSend
                  ? ConfigurationManager.instance.twitchColorDark
                  : Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = !widget.controller.isStarted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                maxLength: 500,
                minLines: 1,
                maxLines: null,
                initialValue: widget.controller.message,
                enabled: canEdit,
                onChanged: (value) =>
                    setState(() => widget.controller.message = value),
                style: TextStyle(color: canEdit ? Colors.black : Colors.grey),
                decoration: InputDecoration(
                    border: const OutlineInputBorder(), labelText: widget.hint),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4),
              child: IconButton(
                  onPressed:
                      widget.controller.isStarted ? null : widget.onDelete,
                  icon: Icon(
                    Icons.delete,
                    color:
                        widget.controller.isStarted ? Colors.grey : Colors.red,
                  )),
            )
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                  width: 120,
                  child: TextFormField(
                    initialValue:
                        widget.controller.interval.inMinutes.toString(),
                    enabled: canEdit,
                    style:
                        TextStyle(color: canEdit ? Colors.black : Colors.grey),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: _setInterval,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Time (min)'),
                  )),
            ),
            SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: widget.controller.delay.inMinutes.toString(),
                  enabled: canEdit,
                  style: TextStyle(color: canEdit ? Colors.black : Colors.grey),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: _setDelay,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Delay first (min)'),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: _buildStartButton(),
            ),
          ],
        ),
      ],
    );
  }
}
