import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/services/socket_service.dart';

class GameManagerService extends ChangeNotifier {
  final SocketService socketService = Get.find();

  void startGame(String? lobbyId) {
    socketService.send(SocketType.Game, GameEvents.StartGame.name);
  }

  void sendCoord(String? lobbyID, Coordinate coord) {
    socketService.send(SocketType.Game, GameEvents.Clic.name,
        {'lobbyId': lobbyID, 'coordClic': coord});
  }
}
