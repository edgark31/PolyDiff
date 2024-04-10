import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/models/lobby_model.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';

class GameManagerService extends ChangeNotifier {
  static Game _game = Game.initial();
  static int _time = 0;
  static String? _endGameMessage;

  // Services
  final SocketService socketService = Get.find();
  final GameAreaService gameAreaService = Get.find();
  final LobbyService lobbyService = Get.find();
  final InfoService infoService = Get.find();
  final GameRecordProvider gameRecordProvider = Get.find();

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

  void updateRemainingDifferences(List<List<Coordinate>>? remaining) {
    _game.differences = remaining;
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

  void setGameRecord(GameRecord record) {
    print('Setting game record');
    gameRecordProvider.setCurrentGameRecord(record);
    notifyListeners();
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
        'isMainCanvas': isLeftCanvas,
      },
    );
  }

  void abandonGame(String? lobbyId) {
    print('AbandonGame called with id: $lobbyId');
    gameAreaService.showDifferenceFound([]);
    socketService.send(SocketType.Game, GameEvents.AbandonGame.name, lobbyId);
  }

  void watchRecordedGame(String lobbyId) {
    print('ReplayCurrentGame called from gameManagerService with id: $lobbyId');
    socketService.send(
        SocketType.Game, GameEvents.WatchRecordedGame.name, lobbyId);
  }

  void saveGameRecord(String lobbyId) {
    print('SaveRecordedGame called from gameManagerService with id: $lobbyId');
    socketService.send(
        SocketType.Game, GameEvents.SaveGameRecord.name, lobbyId);
  }

  void spectateLobby(String? lobbyId) {
    socketService.setup(SocketType.Game, infoService.id);
    setListeners();
    setObserverListener();
    setEndGameMessage(null);
    setGame(Game.initial());
    gameAreaService.coordinates = [];
    socketService.send(SocketType.Game, GameEvents.Spectate.name, lobbyId);
  }

  void setObserverListener() {
    socketService.on(SocketType.Game, GameEvents.Spectate.name, (data) {
      print('Spectate received');
      Map<String, dynamic> returnedInfo = data as Map<String, dynamic>;
      lobbyService.setLobby(
          Lobby.fromJson(returnedInfo['lobby'] as Map<String, dynamic>));
      setGame(Game.fromJson(returnedInfo['game'] as Map<String, dynamic>));
    });
  }

  void disconnectSockets() {
    print('disconnectSockets called');
    socketService.disconnect(SocketType.Game);
    lobbyService.disconnectLobbySocket();
  }

  void activateCheat() {
    socketService.send(
      SocketType.Game,
      GameEvents.CheatActivated.name,
      lobbyService.lobby.lobbyId,
    );
  }

  void deactivateCheat() {
    socketService.send(
      SocketType.Game,
      GameEvents.CheatDeactivated.name,
      lobbyService.lobby.lobbyId,
    );
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
        gameAreaService.showDifferenceNotFound(currentCoord, true);
      } else {
        gameAreaService.showDifferenceNotFound(currentCoord, false);
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
      gameAreaService.showDifferenceFound([]);
      disconnectSockets();
    });

    socketService.on(SocketType.Game, GameEvents.AbandonGame.name, (data) {
      // Returned payload (lobby) is not used
      disconnectSockets();
    });

    socketService.on(SocketType.Game, GameEvents.Cheat.name, (data) {
      List<dynamic> receivedData = data as List<dynamic>;
      final List<List<Coordinate>> remainingDifferences =
          receivedData.map<List<Coordinate>>((entry) {
        return (entry as List)
            .map<Coordinate>(
                (coordinateMap) => Coordinate.fromJson(coordinateMap))
            .toList();
      }).toList();
      updateRemainingDifferences(remainingDifferences);
    });

    socketService.on(SocketType.Game, GameEvents.GameRecord.name, (record) {
      print('GameRecord received');
      if (record is Map<String, dynamic>) {
        setGameRecord(GameRecord.fromJson(record));
        return;
      } else if (record is String) {
        final Map<String, dynamic> parsedRecord = jsonDecode(record);
        setGameRecord(GameRecord.fromJson(parsedRecord));
      } else {
        print('Unexpected data format received: ${record.runtimeType}');
      }
    });
  }
}
