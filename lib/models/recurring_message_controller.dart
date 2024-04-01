import 'dart:async';

import 'package:quiver/collection.dart';
import 'package:twitch_chat_bot/managers/twitch_manager.dart';
import 'package:twitch_chat_bot/models/custom_callback.dart';
import 'package:twitch_chat_bot/models/serializable.dart';

class ReccurringMessageController implements Serializable {
  ReccurringMessageController();

  String message = '';

  bool _isStarted = false;
  bool get isStarted => _isStarted;
  final hasStarted = CustomListener<Function()>();
  final hasStopped = CustomListener<Function()>();

  bool _shouldStartAutomatically = false;
  bool get shouldStartAutomatically => _shouldStartAutomatically;

  Duration _interval = Duration.zero;
  Duration get interval => _interval;
  set interval(Duration value) =>
      _interval = value.inSeconds > 0 ? value : Duration.zero;

  Duration _delay = Duration.zero;
  Duration get delay => _delay;
  set delay(Duration value) =>
      _delay = value.inSeconds > 0 ? value : Duration.zero;

  Timer? _timer;

  bool get isReadyToSend =>
      _interval != Duration.zero &&
      !isStarted &&
      TwitchManager.isConnected &&
      message != '';

  void sendText() => TwitchManager.instance?.chat.send(message);

  void startStreamingText() {
    if (isStarted || _interval == Duration.zero) return;

    if (!isReadyToSend) {
      _shouldStartAutomatically = true;
      return;
    } else {
      _shouldStartAutomatically = false;
    }
    _isStarted = true;
    hasStarted.notifyListerners((callback) => callback());

    Future.delayed(_delay, () {
      if (!_isStarted) return;
      sendText();
      _timer = Timer.periodic(_interval, (timer) async => sendText());
    });
  }

  void stopStreamingText({bool shouldRestartAutomatically = false}) {
    _isStarted = false;
    _shouldStartAutomatically = shouldRestartAutomatically;

    hasStopped.notifyListerners((callback) => callback());
    if (_timer != null) _timer!.cancel();
  }

  @override
  Map<String, dynamic> serialize() => {
        'isStarted': _isStarted,
        'message': message,
        'interval': _interval.inMinutes,
        'delay': _delay.inMinutes,
      };

  static ReccurringMessageController deserialize(Map<String, dynamic> data) {
    final out = ReccurringMessageController();
    out._shouldStartAutomatically = data['isStarted'] ?? false;
    out.message = data['message'] ?? '';
    out._interval = Duration(minutes: data['interval'] ?? 0);
    out._delay = Duration(minutes: data['delay'] ?? 0);
    return out;
  }
}

class ReccurringMessageControllers
    extends DelegatingList<ReccurringMessageController>
    implements Serializable {
  bool activateAtStartup = false;

  final List<ReccurringMessageController> _controllers = [];

  @override
  List<ReccurringMessageController> get delegate => _controllers;

  @override
  Map<String, dynamic> serialize() => {
        'activateAtStartup': activateAtStartup,
        'controllers': _controllers.map((e) => e.serialize()).toList()
      };

  static ReccurringMessageControllers deserialize(Map<String, dynamic> data) {
    final out = ReccurringMessageControllers();
    out.activateAtStartup = data['activateAtStartup'] ?? false;
    out._controllers.addAll((data['controllers'] as List?)
            ?.map((e) => ReccurringMessageController.deserialize(e)) ??
        []);
    return out;
  }
}
