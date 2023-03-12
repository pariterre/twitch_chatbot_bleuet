enum TwitchScope {
  chatRead,
  chatEdit,

  readFollowers,
  readSubscribers
}

extension TwitchScopeStringify on TwitchScope {
  // TODO check if it is needed
  static const colon = '%3A';

  String text() {
    switch (this) {
      case TwitchScope.chatRead:
        return 'chat:read';
      case TwitchScope.chatEdit:
        return 'chat:edit';
      case TwitchScope.readFollowers:
        return 'moderator:read:followers';
      case TwitchScope.readSubscribers:
        return 'channel:read:subscriptions';
    }
  }
}
