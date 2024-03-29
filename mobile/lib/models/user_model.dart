import 'package:mobile/models/friend_model.dart';

class User {
  String username;
  String id;
  List<Friend?> friends;
  List<String?> friendRequests;

  User({
    required this.username,
    required this.id,
    this.friends = const [],
    this.friendRequests = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      id: json['id'],
      friends: List<Friend>.from(json['friends'] ?? []),
      friendRequests: List<String>.from(json['friendRequests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': username,
      'id': id,
      'friends': friends,
      'friendRequests': friendRequests,
    };
  }

  static List<User> usersFromSnapshot(List<Map<String, dynamic>> snapshot) {
    return snapshot.map((e) => User.fromJson(e)).toList();
  }
}
