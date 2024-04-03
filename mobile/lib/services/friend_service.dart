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

  final SocketService socketService = Get.find();

  final InfoService infoService = Get.find();

  List<User> get users => _users;
  List<Friend> get pendingFriends => _pendingFriends;
  List<Friend> get sentFriends => _sentFriends;

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

  void setListeners() {
    socketService.on(SocketType.Auth, UserEvents.UpdateUsers.name, (data) {
      print("Receiving all users");
      List<dynamic> receivedData = data as List<dynamic>;
      List<User> allUsers =
          receivedData.map<User>((user) => User.fromJson(user)).toList();
      updateUsersList(allUsers);
    });

    socketService.on(SocketType.Auth, FriendEvents.UpdatePendingFriends.name,
        (data) {
      print("Receiving all pending");
      List<dynamic> receivedData = data as List<dynamic>;
      List<Friend> allPending = receivedData
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList();
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

    // socketService.on(SocketType.Game, GameEvents.TimerUpdate.name, (data) {
    //   setTime(data as int);
    // });
  }
}
