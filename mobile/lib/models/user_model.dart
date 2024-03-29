import 'package:mobile/models/friend_model.dart';

class UserFriend {
  String username;
  String id;
  List<Friend?> friends;
  List<String?> friendRequests;

  UserFriend({
    required this.username,
    required this.id,
    this.friends = const [],
    this.friendRequests = const [],
  });

  factory UserFriend.fromJson(Map<String, dynamic> json) {
    return UserFriend(
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

  static List<UserFriend> usersFromSnapshot(
      List<Map<String, dynamic>> snapshot) {
    return snapshot.map((e) => UserFriend.fromJson(e)).toList();
  }
}
