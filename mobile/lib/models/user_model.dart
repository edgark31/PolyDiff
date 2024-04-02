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
    return User(
      name: json['name'],
      accountId: json['accountId'],
      friends: List<Friend>.from(json['friends'] ?? []),
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
