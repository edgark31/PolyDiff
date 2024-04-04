import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/friend_model.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';

class FriendService extends ChangeNotifier {
  static List<User> _users = [];
  static List<Friend> _pendingFriends = [];
  static List<Friend> _sentFriends = [];
  static List<Friend> _friends = [];

  final SocketService socketService = Get.find();

  final InfoService infoService = Get.find();

  List<User> get users => _users;
  List<Friend> get pendingFriends => _pendingFriends;
  List<Friend> get sentFriends => _sentFriends;
  List<Friend> get friends => _friends;

  void updateUsersList(List<User> allUsers) {
    _users = allUsers;
    notifyListeners();
  }

  void updatePendingFriends(List<Friend> friends) {
    _pendingFriends = friends;
    notifyListeners();
  }

  void updateSentFriends(List<Friend> friends) {
    _sentFriends = friends;
    notifyListeners();
  }

  void updateFriends(List<Friend> friends) {
    _friends = friends;
    notifyListeners();
  }

  void fetchUsers() {
    print("Fetching users");
    socketService.send(SocketType.Auth, UserEvents.UpdateUsers.name);
  }

  void fetchPending() {
    print("Fetching pending");
    socketService.send(SocketType.Auth, FriendEvents.UpdatePendingFriends.name);
  }

  void fetchSent() {
    print("Fetching sent");
    socketService.send(SocketType.Auth, FriendEvents.UpdateSentFriends.name);
  }

  void fetchFriends() {
    print("Fetching friends");
    socketService.send(SocketType.Auth, FriendEvents.UpdateFriends.name);
  }

  void sendInvite(String potentialFriendId) {
    print("Sending $potentialFriendId");
    socketService.send(SocketType.Auth, FriendEvents.SendRequest.name,
        {'potentialFriendId': potentialFriendId});
  }

  void cancelInvite(String potentialFriendId) {
    print("Cancenlling invite with id: $potentialFriendId");
    socketService.send(SocketType.Auth, FriendEvents.CancelRequest.name,
        {'potentialFriendId': potentialFriendId});
  }

  respondToInvite(String userId, bool isAccept) {
    socketService.send(SocketType.Auth, FriendEvents.OptRequest.name,
        {'senderFriendId': userId, 'isOpt': isAccept});
  }

  removeFriend(String friendId) {
    socketService.send(SocketType.Auth, FriendEvents.DeleteFriend.name,
        {'friendId': friendId});
  }

  void setListeners() {
    socketService.on(SocketType.Auth, UserEvents.UpdateUsers.name, (data) {
      List<dynamic> receivedData = data as List<dynamic>;
      List<User> allUsers =
          receivedData.map<User>((user) => User.fromJson(user)).toList();
      print("Received data of users: $receivedData");
      updateUsersList(allUsers);
    });

    socketService.on(SocketType.Auth, FriendEvents.UpdatePendingFriends.name,
        (data) {
      List<dynamic> receivedData = data as List<dynamic>;
      List<Friend> allPending = receivedData
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList();
      print(receivedData);
      updatePendingFriends(allPending);
    });

    socketService.on(SocketType.Auth, FriendEvents.UpdateSentFriends.name,
        (data) {
      List<dynamic> receivedData = data as List<dynamic>;
      List<Friend> allSent = receivedData
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList();
      updateSentFriends(allSent);
    });

    socketService.on(SocketType.Auth, FriendEvents.UpdateFriends.name, (data) {
      print("UPDATING FRIENDS");
      List<dynamic> receivedData = data as List<dynamic>;
      List<Friend> allFriends = receivedData
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList();
      updateFriends(allFriends);
    });
  }
}
