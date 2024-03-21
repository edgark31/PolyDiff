class Friend {
  String username;
  String avatar;
  List<String> friendUsernames;
  List<String> commonFriendUsernames;
  bool isFavorite;
  bool isOnline;

  Friend({
    required this.username,
    required this.avatar,
    this.friendUsernames = const [],
    this.commonFriendUsernames = const [],
    required this.isFavorite,
    required this.isOnline,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      username: json['username'],
      avatar: json['avatar'],
      friendUsernames: List<String>.from(json['friendUsernames'] ?? []),
      commonFriendUsernames:
          List<String>.from(json['commonFriendUsernames'] ?? []),
      isFavorite: json['isFavorite'],
      isOnline: json['isOnline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': username,
      'avatar': avatar,
      'friendUsernames': friendUsernames,
      'commonFriendNames': commonFriendUsernames,
      'isFavorite': isFavorite,
      'isOnline': isOnline,
    };
  }

  static List<Friend> friendsFromSnapshot(List<Map<String, dynamic>> snapshot) {
    return snapshot.map((e) => Friend.fromJson(e)).toList();
  }
}
