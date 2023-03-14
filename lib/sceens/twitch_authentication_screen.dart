import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '/twitch_models/twitch_models.dart';

class TwitchAuthenticationScreen extends StatefulWidget {
  const TwitchAuthenticationScreen({super.key, required this.nextRoute});
  static const route = '/authentication';
  final String nextRoute;

  @override
  State<TwitchAuthenticationScreen> createState() =>
      _TwitchAuthenticationScreenState();
}

class _TwitchAuthenticationScreenState
    extends State<TwitchAuthenticationScreen> {
  String? _textToShow;
  TwitchManager? _manager;

  @override
  void initState() {
    super.initState();
    _connectToTwitch();
  }

  Future<void> _connectToTwitch() async {
    final navigator = Navigator.of(context);

    // Twitch app informations
    const oauthJsonPath = 'oauth.json';
    String? oauthKey = await File(oauthJsonPath).exists()
        ? jsonDecode(File(oauthJsonPath).readAsStringSync())['oauthKey']
        : null;

    final authentication = TwitchAuthentication(
      oauthKey: oauthKey,
      appId: 'mcysoxq3vitdjwcqn71f8opz11cyex',
      scope: [
        TwitchScope.chatRead,
        TwitchScope.chatEdit,
        TwitchScope.chatters,
        TwitchScope.readFollowers,
        TwitchScope.readSubscribers,
      ],
      moderatorName: 'BotBleuet',
      streamerName: 'pariterre',
    );

    _manager = await TwitchManager.factory(
        authentication: authentication,
        onAuthenticationRequest: _manageRequestUserToBrowse,
        onAuthenticationSuccess: (address) async =>
            _saveOauthKey(address, oauthJsonPath),
        onInvalidToken: _manageInvalidToken);
    navigator.pushReplacementNamed(widget.nextRoute, arguments: _manager);
  }

  Future<void> _manageRequestUserToBrowse(String address) async {
    _textToShow = 'Please navigate to\n$address';
    setState(() {});
  }

  Future<void> _manageInvalidToken() async {
    _textToShow = 'Invalid token, please renew the OAUTH authentication';
  }

  @override
  Widget build(BuildContext context) {
    late Widget widgetToShow;
    if (_textToShow == null) {
      widgetToShow = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Center(child: Text('Please wait while we are logging you')),
          Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          )
        ],
      );
    } else {
      widgetToShow = Center(child: SelectableText(_textToShow!));
    }

    return Scaffold(
      body: widgetToShow,
    );
  }
}

Future<void> _saveOauthKey(String oauthKey, String oauthJsonPath) async {
  final file = File(oauthJsonPath);
  await file.writeAsString(json.encode({'oauthKey': oauthKey}));
}
