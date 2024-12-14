import 'package:flutter/material.dart';
import 'package:twitch_chatbot_bleuet/models/need_love_controller.dart';

class TwitchNeedLoveFormField extends StatefulWidget {
  const TwitchNeedLoveFormField({
    super.key,
    required this.controller,
    required this.hintAddMe,
    required this.hintRemoveMe,
    required this.hintListAll,
    required this.onChanged,
  });

  final NeedLoveController controller;
  final String hintAddMe;
  final String hintRemoveMe;
  final String hintListAll;
  final void Function() onChanged;

  @override
  State<TwitchNeedLoveFormField> createState() =>
      _TwitchNeedLoveFormFieldState();
}

class _TwitchNeedLoveFormFieldState extends State<TwitchNeedLoveFormField> {
  Widget _buildTextFormField(
      {required String initialValue,
      required String hint,
      required Function(String) update}) {
    return TextFormField(
      minLines: 1,
      maxLines: 1,
      initialValue: initialValue,
      enabled: true,
      onChanged: (value) {
        update(value);
        widget.onChanged();
        setState(() {});
      },
      style: const TextStyle(color: Colors.black),
      decoration:
          InputDecoration(border: const OutlineInputBorder(), labelText: hint),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            'Allows for users to add themselves to a list of users who need love.',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.addUserCommand,
          hint: widget.hintAddMe,
          update: (value) => widget.controller.addUserCommand = value,
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.removeUserCommand,
          hint: widget.hintRemoveMe,
          update: (value) => widget.controller.removeUserCommand = value,
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.listUsersCommand,
          hint: widget.hintListAll,
          update: (value) => widget.controller.listUsersCommand = value,
        ),
        const SizedBox(height: 12),
        Text(
            'Responses sent to the chat. '
            'The following tags can be used:',
            style: Theme.of(context).textTheme.titleSmall),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\$USER \u2014 The user who sends the command;'),
              Text('\$USERS \u2014 The list of users who need love;'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.userAddedResponse,
          hint: 'The response to a new user was added',
          update: (value) => widget.controller.userAddedResponse = value,
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.userAlreadyRegisteredResponse,
          hint: 'The response to a user already registered',
          update: (value) =>
              widget.controller.userAlreadyRegisteredResponse = value,
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.userRemovedResponse,
          hint: 'The response to a user being removed',
          update: (value) => widget.controller.userRemovedResponse = value,
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.userNotRegisteredResponse,
          hint: 'The response to a user not being registered',
          update: (value) =>
              widget.controller.userNotRegisteredResponse = value,
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.listUsersResponse,
          hint: 'The response to listing all users',
          update: (value) => widget.controller.listUsersResponse = value,
        ),
        const SizedBox(height: 8),
        _buildTextFormField(
          initialValue: widget.controller.listUsersEmptyResponse,
          hint: 'The response to listing no users',
          update: (value) => widget.controller.listUsersEmptyResponse = value,
        ),
      ],
    );
  }
}
