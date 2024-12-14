import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitch_chatbot_bleuet/managers/configuration_manager.dart';
import 'package:twitch_chatbot_bleuet/managers/twitch_manager.dart';
import 'package:twitch_chatbot_bleuet/models/command_controller.dart';
import 'package:twitch_chatbot_bleuet/models/instant_message_controller.dart';
import 'package:twitch_chatbot_bleuet/models/need_love_controller.dart';
import 'package:twitch_chatbot_bleuet/models/recurring_message_controller.dart';
import 'package:twitch_chatbot_bleuet/widgets/twitch_command_formfield.dart';
import 'package:twitch_chatbot_bleuet/widgets/twitch_instant_message_formfield.dart';
import 'package:twitch_chatbot_bleuet/widgets/twitch_need_love_formfield.dart';
import 'package:twitch_chatbot_bleuet/widgets/twitch_recurring_message_formfield.dart';
import 'package:twitch_manager/twitch_app.dart';

class TwitchChatBotScreen extends StatefulWidget {
  const TwitchChatBotScreen({super.key});

  @override
  State<TwitchChatBotScreen> createState() => _TwitchChatBotScreenState();
}

class _TwitchChatBotScreenState extends State<TwitchChatBotScreen> {
  final InstantMessageController _instantMessageController =
      InstantMessageController();

  bool _isLoading = true;
  ReccurringMessageControllers? _recurringMessageControllers;
  CommandControllers? _commandControllers;
  NeedLoveController? _needLoveController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final cm = ConfigurationManager.instance;

    return TwitchAppDebugOverlay(
      manager: TwitchManager.instance,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Twitch chatbot'),
          backgroundColor: cm.twitchColorDark,
          foregroundColor: Colors.white,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: cm.twitchColorLight),
          child: Center(
            child: SizedBox(
              width: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ..._buildConnexion(),
                  Expanded(
                    child: SizedBox(
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25)),
                            ),
                          ),
                          if (_isLoading || _isTwitchChangingStatus)
                            const Center(child: CircularProgressIndicator()),
                          if (!_isLoading && !_isTwitchChangingStatus)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    ..._buildInstantMessage(),
                                    const Divider(),
                                    ..._buildRecurringMessage(),
                                    const Divider(),
                                    ..._buildCommand(),
                                    const Divider(),
                                    ..._buildNeedLove(),
                                    const Divider(),
                                    const SizedBox(height: 200),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonDecode(prefs.getString('chatbotData') ?? '{}');

    _recurringMessageControllers = ReccurringMessageControllers.deserialize(
        data['recurringMessages'] ?? {});
    _commandControllers =
        CommandControllers.deserialize(data['commands'] ?? {});
    _needLoveController =
        NeedLoveController.deserialize(data['needLove'] ?? {});

    _isLoading = false;
    setState(() {});

    if (data['canAutoConnectToTwitch'] ?? false) _connectToTwitch();
  }

  void _saveChanges() async {
    final data = {
      'canAutoConnectToTwitch': TwitchManager.instance?.isConnected ?? false,
      'recurringMessages': _recurringMessageControllers!.serialize(),
      'commands': _commandControllers!.serialize(),
      'needLove': _needLoveController!.serialize(),
    };

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('chatbotData', jsonEncode(data));
  }

  List<Widget> _buildConnexion() {
    return [
      const SizedBox(height: 18),
      Text('Connexion panel', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: _connectToTwitch,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6441a5),
            foregroundColor: Colors.white),
        child: Text(TwitchManager.instance?.isConnected ?? false
            ? 'Disconnect from twitch'
            : 'Connect to Twitch'),
      ),
      const SizedBox(height: 18),
    ];
  }

  bool _isTwitchChangingStatus = false;

  Future<void> _connectToTwitch() async {
    setState(() => _isTwitchChangingStatus = true);

    if (TwitchManager.isConnected) {
      await TwitchManager.instance?.disconnect();

      _recurringMessageControllers?.forEach((controller) {
        controller.stopStreamingText(
            shouldRestartAutomatically: controller.isStarted);
      });
    } else {
      TwitchManager.initialize(await showDialog(
          context: context,
          builder: (ctx) => TwitchAppAuthenticationDialog(
                isMockActive: ConfigurationManager.instance.useTwitchMock,
                onConnexionEstablished: (manager) =>
                    Navigator.of(context).pop(manager),
                appInfo: ConfigurationManager.instance.twitchAppInfo,
                reload: true,
                debugPanelOptions:
                    ConfigurationManager.instance.twitchDebugOptions,
              )));

      TwitchManager.instance!.chat.onMessageReceived.listen(_onMessageReceived);

      _recurringMessageControllers?.forEach((controller) {
        if (controller.shouldStartAutomatically) {
          controller.startStreamingText();
        }
      });
    }

    _saveChanges();
    setState(() => _isTwitchChangingStatus = false);
  }

  List<Widget> _buildInstantMessage() {
    return [
      const SizedBox(height: 12),
      Text('Send an instant message',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      TwitchInstantMessageFormField(
          controller: _instantMessageController, hint: 'The message to send'),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _buildRecurringMessage() {
    return [
      const SizedBox(height: 12),
      Text('Recurring messages', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      ..._recurringMessageControllers!.map(
        (controller) => Column(
          children: [
            TwitchRecurringMessageFormField(
                key: ObjectKey(controller),
                controller: controller,
                hint: 'The recurring message to send',
                onChanged: _saveChanges,
                onDelete: () => setState(
                    () => _recurringMessageControllers!.remove(controller))),
            const SizedBox(height: 12),
            const SizedBox(
                width: 450,
                child: Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
      ElevatedButton(
        onPressed: () => setState(() =>
            _recurringMessageControllers!.add(ReccurringMessageController())),
        child: const Text('(+) Add reccurring message'),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _buildCommand() {
    return [
      const SizedBox(height: 12),
      Text('Chatbot commands', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      ..._commandControllers!.map(
        (controller) => Column(
          children: [
            TwitchCommandFormField(
                controller: controller,
                key: ObjectKey(controller),
                hintCommand: 'The chat command to listen to',
                hintAnswer: 'The response message',
                onChanged: _saveChanges,
                onDelete: () =>
                    setState(() => _commandControllers!.remove(controller))),
            const SizedBox(height: 12),
            const SizedBox(
                width: 450,
                child: Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: () =>
            setState(() => _commandControllers!.add(CommandController())),
        child: const Text('(+) Add command'),
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _buildNeedLove() {
    return [
      const SizedBox(height: 12),
      Text('Need love commands', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      TwitchNeedLoveFormField(
        controller: _needLoveController!,
        hintAddMe: 'The chat command to add a user to the list',
        hintRemoveMe: 'The chat command to remove a user from the list',
        hintListAll: 'The chat command to list all users who need love',
        onChanged: _saveChanges,
      ),
      const SizedBox(height: 12),
    ];
  }

  void _onMessageReceived(String sender, String message) {
    message = message.toLowerCase();

    // Bot commands section
    for (final controller in _commandControllers!) {
      if (controller.isActive && controller.command.toLowerCase() == message) {
        TwitchManager.instance?.chat.send(controller.answer);
      }
    }

    // Need love section
    final reponseToNeedLove =
        _needLoveController?.responseToIncoming(message, sender);
    if (reponseToNeedLove != null) {
      TwitchManager.instance?.chat.send(reponseToNeedLove);
    }
  }
}
