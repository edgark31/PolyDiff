import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/lobby_model.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';

class GameManagerService extends ChangeNotifier {
  static Game _game = Game.initial();
  static int _time = 0;
  final SocketService socketService = Get.find();
  final GameAreaService gameAreaService = Get.find();
  final LobbyService lobbyService = Get.find();

  Game get game => _game;
  int get time => _time;

  void setGame(Game newGame) {
    print('new Game has been setted $game');
    _game = newGame;
    notifyListeners();
  }

  void setTime(int newTime) {
    print("New time setted");
    _time = newTime;
    notifyListeners();
  }

  void startGame(String? lobbyId) {
    print("Calling gamemanager start game");
    socketService.send(SocketType.Game, GameEvents.StartGame.name, lobbyId);
  }

  void sendCoord(String? lobbyID, Coordinate coord) {
    socketService.send(
      SocketType.Game,
      GameEvents.Click.name,
      {
        'lobbyId': lobbyID,
        'coordClic': coord,
      },
    );
  }

  void setListeners() {
    socketService.on(SocketType.Game, GameEvents.StartGame.name, (data) {
      print('StartGameReceived');
      setGame(Game.fromJson(data as Map<String, dynamic>));
    });

    socketService.on(SocketType.Game, GameEvents.Found.name, (data) {
      Map<String, dynamic> returnedInfo = data as Map<String, dynamic>;
      lobbyService.setLobby(
          Lobby.fromJson(returnedInfo['lobby'] as Map<String, dynamic>));
      List<Coordinate> coord = returnedInfo['difference']
          .map<Coordinate>((coordinate) => Coordinate.fromJson(coordinate))
          .toList();
      gameAreaService.showDifferenceFound(coord);
    });

    socketService.on(SocketType.Game, GameEvents.TimerUpdate.name, (data) {
      print("Time received");
      setTime(data as int);
    });

    // socketService.on(SocketType.Game, GameEvents.EndGame.name, (data) {
    //   print(data as String?); // Server sending 'Temps écoulé !'
    //   print('GameEvents.EndGame.name event received');
    // });

    // socketService.on(SocketType.Game, GameEvents.TimerUpdate.name, (data) {
    //   print(data as String?); // Server sending 'Temps écoulé !'
    //   print('GameEvents.EndGame.name event received');
    // });
  }
}
