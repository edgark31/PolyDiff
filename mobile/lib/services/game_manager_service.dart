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
  static String? _endGameMessage;
  final SocketService socketService = Get.find();
  final GameAreaService gameAreaService = Get.find();
  final LobbyService lobbyService = Get.find();
  bool isLeftCanvas = true;

  VoidCallback? onGameChange;
  Game get game => _game;
  int get time => _time;
  String? get endGameMessage => _endGameMessage;

  void setGame(Game newGame) {
    print('new Game has been setted $game');
    _endGameMessage = null;
    _game = newGame;
    notifyListeners();
    onGameChange?.call();
    notifyListeners();
  }

  void setTime(int newTime) {
    _time = newTime;
    notifyListeners();
  }

  void setEndGameMessage(String? newEndGameMessage) {
    print("New EndGameMessage setted : $newEndGameMessage");
    _endGameMessage = newEndGameMessage;
    notifyListeners();
  }

  void setIsLeftCanvas(isLeft) {
    isLeftCanvas = isLeft;
  }

  void startGame(String? lobbyId) {
    print("Calling gamemanager start game");
    gameAreaService.coordinates = [];
    socketService.send(SocketType.Game, GameEvents.StartGame.name, lobbyId);
  }

  void setupGame() {
    setListeners();
    setEndGameMessage(null);
    setGame(Game.initial());
    startGame(lobbyService.lobby.lobbyId);
  }

  void sendCoord(String? lobbyId, Coordinate coord) {
    print(
        'SendCoord is called with id: $lobbyId and coord: x: ${coord.x} y: ${coord.y}');
    socketService.send(
      SocketType.Game,
      GameEvents.Clic.name,
      {
        'lobbyId': lobbyId,
        'coordClic': coord,
      },
    );
  }

  void abandonGame(String? lobbyId) {
    socketService.send(SocketType.Game, GameEvents.AbandonGame.name, lobbyId);
    socketService.disconnect(SocketType.Game);
    if (lobbyService.lobby.players.length < 2) {
      lobbyService.endLobby();
    }
  }

  void setListeners() {
    socketService.on(SocketType.Game, GameEvents.StartGame.name, (data) {
      print('StartGameReceived');
      setGame(Game.fromJson(data as Map<String, dynamic>));
    });

    socketService.on(SocketType.Game, GameEvents.Found.name, (data) {
      print("Difference Found");
      Map<String, dynamic> returnedInfo = data as Map<String, dynamic>;
      lobbyService.setLobby(
          Lobby.fromJson(returnedInfo['lobby'] as Map<String, dynamic>));
      List<Coordinate> coord = returnedInfo['difference']
          .map<Coordinate>((coordinate) => Coordinate.fromJson(coordinate))
          .toList();
      gameAreaService.showDifferenceFound(coord);
    });

    socketService.on(SocketType.Game, GameEvents.NotFound.name, (data) {
      print("showing error");
      Coordinate currentCoord =
          Coordinate.fromJson(data as Map<String, dynamic>);
      if (isLeftCanvas) {
        gameAreaService.showDifferenceNotFoundLeft(currentCoord);
      } else {
        gameAreaService.showDifferenceNotFoundRight(currentCoord);
      }
    });

    socketService.on(SocketType.Game, GameEvents.TimerUpdate.name, (data) {
      setTime(data as int);
    });

    socketService.on(SocketType.Game, GameEvents.NextGame.name, (data) {
      gameAreaService.coordinates = [];
      setGame(Game.fromJson(data as Map<String, dynamic>));
    });

    socketService.on(SocketType.Game, GameEvents.EndGame.name, (data) {
      setEndGameMessage(data as String?);
      socketService.disconnect(SocketType.Game);
      lobbyService.endLobby();
    });
  }
}
