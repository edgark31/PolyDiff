import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/services/socket_service.dart';

class GameManagerService extends ChangeNotifier {
  static Game _game = Game.initial();
  final SocketService socketService = Get.find();

  Game get game => _game;

  void setGame(Game newGame) {
    _game = newGame;
    notifyListeners();
  }

  void startGame(String? lobbyId) {
    socketService.send(SocketType.Game, GameEvents.StartGame.name, lobbyId);
  }

  void sendCoord(String? lobbyID, Coordinate coord) {
    socketService.send(
      SocketType.Game,
      GameEvents.Clic.name,
      {
        'lobbyId': lobbyID,
        'coordClic': coord,
      },
    );
  }

  void setListeners() {
    socketService.on(SocketType.Game, GameEvents.StartGame.name, (data) {
      setGame(Game.fromJson(data as Map<String, dynamic>));
    });

    socketService.on(SocketType.Game, GameEvents.Clic.name, (data) {
      print('GameEvents.Clic.name event received');
    });

    socketService.on(SocketType.Game, GameEvents.EndGame.name, (data) {
      print(data as String?); // Server sending 'Temps écoulé !'
      print('GameEvents.EndGame.name event received');
    });

    socketService.on(SocketType.Game, GameEvents.TimerUpdate.name, (data) {
      print(data as String?); // Server sending 'Temps écoulé !'
      print('GameEvents.EndGame.name event received');
    });
  }
}
