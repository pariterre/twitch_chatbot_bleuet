import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

import 'twitch_models.dart';

// Define some constant from Twitch itself
const _ircServerAddress = 'irc.chat.twitch.tv';
const _ircPort = 6667;
const _regexpMessage = r'^:(.*)!.*@.*PRIVMSG.*#.*:(.*)$';

class TwitchIrc {
  final TwitchCredentials ircCredentials;

  final Socket _socket;
  bool isConnected = false;

  Function(String sender, String message)? messageCallback;
  Function(String message)? twitchCallback;

  ///
  /// Main constructor
  ///
  static Future<TwitchIrc> factory(
    TwitchCredentials ircCredentials, {
    required TwitchAuthenticator authenticator,
  }) async {
    return TwitchIrc._(
      await Socket.connect(_ircServerAddress, _ircPort),
      ircCredentials,
      authenticator,
    );
  }

  ///
  /// Private constructor
  ///
  TwitchIrc._(
      this._socket, this.ircCredentials, TwitchAuthenticator authenticator) {
    _connect(authenticator: authenticator);
    // TODO: add finalizer
  }

  ///
  /// Send a [message] to the chat of the channel
  ///
  void send(String message) {
    _send('PRIVMSG #${ircCredentials.streamerName} :$message');
  }

  ///
  /// Send a message to Twitch IRC
  ///
  void _send(String command) {
    _socket.write('$command\n');
  }

  ///
  /// Connect to Twitch IRC
  void _connect({required TwitchAuthenticator authenticator}) {
    _socket.listen(_messageReceived);
    isConnected = true;

    _send('PASS oauth:${authenticator.oauthKey}');
    _send('NICK ${ircCredentials.moderatorName}');
    _send('JOIN #${ircCredentials.streamerName}');
  }

  ///
  /// Disconnect to Twitch IRC
  Future<void> _disconnect() async {
    _send('PART ${ircCredentials.streamerName}');

    await _socket.close(); // TODO: this does not seem to work
    isConnected = false;
  }

  ///
  /// This method is called each time a new message is sent
  ///
  void _messageReceived(Uint8List data) {
    var response = String.fromCharCodes(data);
    // Remove the line returns
    if (response[response.length - 1] == '\n') {
      response = response.substring(0, response.length - 1);
    }
    if (response[response.length - 1] == '\r') {
      response = response.substring(0, response.length - 1);
    }

    if (response == 'PING :tmi.twitch.tv') {
      // Keep connexion alive
      _send('PONG :tmi.twitch.tv');
      log(response);
      return;
    }

    final re = RegExp(_regexpMessage);
    final match = re.firstMatch(response);
    if (match == null || match.groupCount != 2) {
      log(response);
      if (twitchCallback != null) twitchCallback!(response);
      return;
    }

    final sender = match.group(1)!;
    final message = match.group(2)!;
    log('Message received:\n$sender: $message');

    if (messageCallback != null) messageCallback!(sender, message);
  }
}
