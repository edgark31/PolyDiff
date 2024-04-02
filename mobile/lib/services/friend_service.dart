import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';

class FriendService extends ChangeNotifier {
  static List<User> _users = [];

  final SocketService socketService = Get.find();

  final InfoService infoService = Get.find();

  List<User> get users => _users;

  void updateUsersList(List<User> allUsers) {
    _users = allUsers;
    notifyListeners();
  }

  void fetchUsers() {
    socketService.send(SocketType.Auth, UserEvents.UpdateUsers.name);
  }

  void setListeners() {
    socketService.on(SocketType.Auth, UserEvents.UpdateUsers.name, (data) {
      print("Receiving all users");
      List<dynamic> receivedData = data as List<dynamic>;
      List<User> allUsers =
          receivedData.map<User>((user) => User.fromJson(user)).toList();
      print(allUsers);
    });

    // socketService.on(SocketType.Game, GameEvents.TimerUpdate.name, (data) {
    //   setTime(data as int);
    // });
  }
}
