import 'package:quiver/collection.dart';
import 'package:twitch_chat_bot/models/serializable.dart';

class CommandController implements Serializable {
  String command = '';
  String answer = '';

  bool isActive = false;

  @override
  Map<String, dynamic> serialize() =>
      {'command': command, 'answer': answer, 'isActive': isActive};

  static CommandController deserialize(Map<String, dynamic> data) {
    final out = CommandController();
    out.command = data['command'];
    out.answer = data['answer'];
    out.isActive = data['isActive'];
    return out;
  }
}

class CommandControllers extends DelegatingList<CommandController>
    implements Serializable {
  final List<CommandController> _controllers = [];

  @override
  List<CommandController> get delegate => _controllers;

  @override
  Map<String, dynamic> serialize() =>
      {'controllers': _controllers.map((e) => e.serialize()).toList()};

  static CommandControllers deserialize(Map<String, dynamic> data) {
    final out = CommandControllers();
    out._controllers.addAll((data['controllers'] as List?)
            ?.map((e) => CommandController.deserialize(e)) ??
        []);
    return out;
  }
}
