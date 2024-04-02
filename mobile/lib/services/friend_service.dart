import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';

class FriendService extends ChangeNotifier {
  // static Game _game = Game.initial();
  static List<User> users = [];

  final SocketService socketService = Get.find();

  final LobbyService lobbyService = Get.find();
  final InfoService infoService = Get.find();

  // Game get game => _game;

  // void updateRemainingDifferences(List<List<Coordinate>>? remaining) {
  //   _game.differences = remaining;
  //   notifyListeners();
  // }

  // void fetchUsers()

  void setListeners() {
    // socketService.on(SocketType.Game, GameEvents.Found.name, (data) {
    //   print("Difference Found");
    //   Map<String, dynamic> returnedInfo = data as Map<String, dynamic>;
    //   lobbyService.setLobby(
    //       Lobby.fromJson(returnedInfo['lobby'] as Map<String, dynamic>));
    //   List<Coordinate> coord = returnedInfo['difference']
    //       .map<Coordinate>((coordinate) => Coordinate.fromJson(coordinate))
    //       .toList();
    //   gameAreaService.showDifferenceFound(coord);
    // });

    // socketService.on(SocketType.Game, GameEvents.TimerUpdate.name, (data) {
    //   setTime(data as int);
    // });
  }
}
