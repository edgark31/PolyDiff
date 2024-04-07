import 'package:mobile/models/friend_model.dart';

class User {
  String name;
  String accountId;
  List<Friend?> friends;
  List<String?> friendRequests;

  User({
    required this.name,
    required this.accountId,
    this.friends = const [],
    this.friendRequests = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['friends'] == []) {
      json['friends'] = List<Friend>.empty();
    }
    return User(
      name: json['name'],
      accountId: json['accountId'],
      friends: json['friends']
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList(),
      friendRequests: List<String>.from(json['friendRequests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'accountId': accountId,
      'friends': friends,
      'friendRequests': friendRequests,
    };
  }

  static List<User> usersFromSnapshot(List<Map<String, dynamic>> snapshot) {
    return snapshot.map((e) => User.fromJson(e)).toList();
  }
}
