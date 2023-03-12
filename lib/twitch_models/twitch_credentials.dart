class TwitchCredentials {
  ///
  /// [streamerName] is the name of the channel to connect
  /// [moderatorName] is the name of the current logged in moderator. If it is
  /// left empty [streamerName] is used
  TwitchCredentials({required this.streamerName, String? moderatorName})
      : moderatorName = moderatorName ?? streamerName;

  final String streamerName;
  final String moderatorName;
}
