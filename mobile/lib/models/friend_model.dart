class Friend {
  String name;
  String accountId;
  List<Friend?> friends;
  List<Friend?> commonFriends;
  bool? isOnline;
  bool? isFavorite;

  Friend({
    required this.name,
    required this.accountId,
    this.friends = const [],
    this.commonFriends = const [],
    required this.isOnline,
    required this.isFavorite,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    if (json['friends'] == [] || json['friends'] == null) {
      json['friends'] = List<Friend>.empty();
    }

    if (json['commonFriends'] == [] || json['commonFriends'] == null) {
      json['commonFriends'] = List<Friend>.empty();
    }
    return Friend(
      name: json['name'],
      accountId: json['accountId'],
      friends: json['friends']
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList(),
      commonFriends: json['commonFriends']
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList(),
      isOnline: json['isOnline'],
      isFavorite: json['isFavorite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'accountId': accountId,
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
