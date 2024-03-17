class Friend {
  String name;
  String avatar;
  List<String> friendNames;
  List<String> commonFriendNames;
  bool isFavorite;
  bool isOnline;

  Friend({
    required this.name,
    required this.avatar,
    this.friendNames = const [],
    this.commonFriendNames = const [],
    required this.isFavorite,
    required this.isOnline,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['name'],
      avatar: json['avatar'],
      friendNames: List<String>.from(json['friendNames'] ?? []),
      commonFriendNames: List<String>.from(json['commonFriendNames'] ?? []),
      isFavorite: json['isFavorite'],
      isOnline: json['isOnline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'friendNames': friendNames,
      'commonFriendNames': commonFriendNames,
      'isFavorite': isFavorite,
      'isOnline': isOnline,
    };
  }
}
