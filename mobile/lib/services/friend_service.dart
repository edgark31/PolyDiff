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
  static List<Friend> _friendsOfFriends = [];
  static List<Friend> _commonFriends = [];

  final SocketService socketService = Get.find();
  final InfoService infoService = Get.find();

  List<User> get users => _users;
  List<Friend> get pendingFriends => _pendingFriends;
  List<Friend> get sentFriends => _sentFriends;
  List<Friend> get friends => _friends;
  List<Friend> get friendsOfFriends => _friendsOfFriends;
  List<Friend> get commonFriend => _commonFriends;

  bool isInviteDisabled = false;
  bool isCancelDisabled = false;
  bool isResponseDisabled = false;

  void updateUsersList(List<User> allUsers) {
    allUsers.sort((a, b) => a.name.compareTo(b.name));
    _users = allUsers;
    notifyListeners();
  }

  void updatePendingFriends(List<Friend> friends) {
    friends.sort((a, b) => a.name.compareTo(b.name));
    _pendingFriends = friends;
    notifyListeners();
  }

  void updateSentFriends(List<Friend> friends) {
    friends.sort((a, b) => a.name.compareTo(b.name));
    _sentFriends = friends;
    notifyListeners();
  }

  void updateFriends(List<Friend> friends) {
    friends.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return a.name.compareTo(b.name);
    });
    _friends = friends;
    notifyListeners();
  }

  void updateCommon(List<Friend> friends) {
    friends.sort((a, b) => a.name.compareTo(b.name));
    _commonFriends = friends;
    notifyListeners();
  }

  void updateFoFs(List<Friend> friends) {
    friends.sort((a, b) => a.name.compareTo(b.name));
    _friendsOfFriends = friends;
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

  void fetchCommon(String friendId) {
    print("Fetching commonFriends");
    socketService.send(SocketType.Auth, FriendEvents.UpdateCommonFriends.name,
        {'friendId': friendId});
  }

  void fetchFoFs(String friendId) {
    print("Fetching FriendsOfFriends with id: $friendId");
    socketService.send(
        SocketType.Auth, FriendEvents.UpdateFoFs.name, {'friendId': friendId});
  }

  void sendInvite(String potentialFriendId) {
    print("Sending $potentialFriendId");
    isInviteDisabled = true;
    socketService.send(SocketType.Auth, FriendEvents.SendRequest.name,
        {'potentialFriendId': potentialFriendId});
    Future.delayed(Duration(seconds: (3)), () {
      isInviteDisabled = false;
    });
  }

  void cancelInvite(String potentialFriendId) {
    print("Cancelling invite with id: $potentialFriendId");
    isCancelDisabled = true;
    socketService.send(SocketType.Auth, FriendEvents.CancelRequest.name,
        {'potentialFriendId': potentialFriendId});
    Future.delayed(Duration(seconds: (3)), () {
      isCancelDisabled = false;
    });
  }

  respondToInvite(String userId, bool isAccept) {
    print("Responding to invite with $isAccept");
    isResponseDisabled = true;
    socketService.send(SocketType.Auth, FriendEvents.OptRequest.name,
        {'senderFriendId': userId, 'isOpt': isAccept});
    Future.delayed(Duration(seconds: (3)), () {
      isResponseDisabled = false;
    });
  }

  removeFriend(String friendId) {
    socketService.send(SocketType.Auth, FriendEvents.DeleteFriend.name,
        {'friendId': friendId});
  }

  void toggleFavorite(String friendId, bool isFavorite) {
    socketService.send(SocketType.Auth, FriendEvents.OptFavorite.name,
        {'friendId': friendId, 'isFavorite': isFavorite});
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
      print('Received friends: $receivedData');
      List<Friend> allFriends = receivedData
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList();
      updateFriends(allFriends);
    });

    socketService.on(SocketType.Auth, FriendEvents.UpdateCommonFriends.name,
        (data) {
      print("UPDATING Common");
      List<dynamic> receivedData = data as List<dynamic>;
      List<Friend> commonFriends = receivedData
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList();
      updateCommon(commonFriends);
    });

    socketService.on(SocketType.Auth, FriendEvents.UpdateFoFs.name, (data) {
      print("UPDATING FOF");
      List<dynamic> receivedData = data as List<dynamic>;
      List<Friend> friendsOfFriends = receivedData
          .map<Friend>((friend) => Friend.fromJson(friend))
          .toList();
      updateFoFs(friendsOfFriends);
    });
  }
}
