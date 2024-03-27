class Friend {
  String username;
  String id;
  List<Friend?> friends;
  List<Friend?> commonFriends;
  bool isOnline;
  bool isFavorite;

  Friend({
    required this.username,
    required this.id,
    this.friends = const [],
    this.commonFriends = const [],
    required this.isOnline,
    required this.isFavorite,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      username: json['username'],
      id: json['id'],
      friends: List<Friend>.from(json['friends'] ?? []),
      commonFriends: List<Friend>.from(json['commonFriends'] ?? []),
      isOnline: json['isOnline'],
      isFavorite: json['isFavorite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': username,
      'id': id,
      'friends': friends,
      'commonFriends': commonFriends,
      'isOnline': isOnline,
      'isFavorite': isFavorite,
    };
  }

  static List<Friend> friendsFromSnapshot(List<Map<String, dynamic>> snapshot) {
    return snapshot.map((e) => Friend.fromJson(e)).toList();
  }
}
