import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twitch_chat_bot/managers/configuration_manager.dart';
import 'package:twitch_chat_bot/models/recurring_message_controller.dart';

class TwitchRecurringMessageFormField extends StatefulWidget {
  const TwitchRecurringMessageFormField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onDelete,
  });

  final ReccurringMessageController controller;
  final String hint;
  final void Function() onChanged;
  final void Function() onDelete;

  @override
  State<TwitchRecurringMessageFormField> createState() =>
      _TwitchRecurringMessageFormFieldState();
}

class _TwitchRecurringMessageFormFieldState
    extends State<TwitchRecurringMessageFormField> {
  @override
  void initState() {
    super.initState();
    widget.controller.hasStarted.startListening(_refresh);
    widget.controller.hasStopped.startListening(_refresh);
  }

  @override
  void dispose() {
    widget.controller.hasStarted.stopListening(_refresh);
    widget.controller.hasStopped.stopListening(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _setInterval(String value) {
    int? time = int.tryParse(value);
    widget.controller.interval =
        time == null ? Duration.zero : Duration(minutes: time);
    widget.onChanged();
    setState(() {});
  }

  void _setDelay(String value) {
    int? time = int.tryParse(value);
    widget.controller.delay =
        time == null ? Duration.zero : Duration(minutes: time);
    widget.onChanged();
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
                onChanged: (value) {
                  widget.controller.message = value;
                  widget.onChanged();
                  setState(() {});
                },
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
              child: IconButton(
                  onPressed: () {
                    widget.controller.isStarted ||
                            widget.controller.shouldStartAutomatically
                        ? widget.controller.stopStreamingText()
                        : widget.controller.startStreamingText();
                    widget.onChanged();
                    setState(() {});
                  },
                  icon: Icon(
                      widget.controller.isStarted ||
                              widget.controller.shouldStartAutomatically
                          ? Icons.pause
                          : Icons.send,
                      color: ConfigurationManager.instance.twitchColorDark)),
            ),
          ],
        ),
      ],
    );
  }
}
