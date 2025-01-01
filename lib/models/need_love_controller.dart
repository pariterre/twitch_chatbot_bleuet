import 'package:twitch_chatbot_bleuet/models/serializable.dart';

String _formatString(String toFormat,
    {required String user, required List<String> users}) {
  return toFormat
      .replaceAll('\$USERS', users.join(', '))
      .replaceAll('\$USER', user);
}

class NeedLoveController implements Serializable {
  final List<String> _usersWhoNeedLove = [];

  String addUserCommand = '!ineedLove';
  String removeUserCommand = '!idontNeedLove';
  String listUsersCommand = '!whoNeedsLove';

  String userAddedResponse =
      '\$USER was added to the list of users who need love';
  String userAlreadyRegisteredResponse = '\$USER already needs love';
  String userRemovedResponse =
      '\$USER was removed from the list of users who need love';
  String userNotRegisteredResponse = '\$USER did not needed love anyway';

  String listUsersResponse = 'Users who need love: \$USERS';
  String listUsersEmptyResponse = 'No user needs love';

  @override
  Map<String, dynamic> serialize() => {
        'addUserCommand': addUserCommand,
        'removeUserCommand': removeUserCommand,
        'listUsersCommand': listUsersCommand,
        'userAddedResponse': userAddedResponse,
        'userAlreadyRegisteredResponse': userAlreadyRegisteredResponse,
        'userRemovedResponse': userRemovedResponse,
        'userNotRegisteredResponse': userNotRegisteredResponse,
        'listUsersResponse': listUsersResponse,
        'listUsersEmptyResponse': listUsersEmptyResponse,
      };

  static NeedLoveController deserialize(Map<String, dynamic> data) {
    final out = NeedLoveController();
    out.addUserCommand = data['addUserCommand'] ?? out.addUserCommand;
    out.removeUserCommand = data['removeUserCommand'] ?? out.removeUserCommand;
    out.listUsersCommand = data['listUsersCommand'] ?? out.listUsersCommand;
    out.userAddedResponse = data['userAddedResponse'] ?? out.userAddedResponse;
    out.userAlreadyRegisteredResponse = data['userAlreadyRegisteredResponse'] ??
        out.userAlreadyRegisteredResponse;
    out.userRemovedResponse =
        data['userRemovedResponse'] ?? out.userRemovedResponse;
    out.userNotRegisteredResponse =
        data['userNotRegisteredResponse'] ?? out.userNotRegisteredResponse;
    out.listUsersResponse = data['listUsersResponse'] ?? out.listUsersResponse;
    out.listUsersEmptyResponse =
        data['listUsersEmptyResponse'] ?? out.listUsersEmptyResponse;
    return out;
  }

  String? responseToIncoming(String message, String sender) {
    String? responseToFormat;
    if (message == addUserCommand.toLowerCase()) {
      if (_usersWhoNeedLove.contains(sender)) {
        responseToFormat = userAlreadyRegisteredResponse;
      } else {
        _usersWhoNeedLove.add(sender);
        responseToFormat = userAddedResponse;
      }
    } else if (message == removeUserCommand.toLowerCase()) {
      if (_usersWhoNeedLove.contains(sender)) {
        _usersWhoNeedLove.remove(sender);
        responseToFormat = userRemovedResponse;
      } else {
        responseToFormat = userNotRegisteredResponse;
      }
    } else if (message == listUsersCommand.toLowerCase()) {
      responseToFormat = _usersWhoNeedLove.isEmpty
          ? listUsersEmptyResponse
          : listUsersResponse;
    }

    return responseToFormat == null
        ? null
        : _formatString(responseToFormat,
            user: sender, users: _usersWhoNeedLove);
  }
}
