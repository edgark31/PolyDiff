import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/socket_service.dart';

class LobbyService extends ChangeNotifier {
  static GameModes _gameModes = GameModes.Classic;
  static String _gameModesName = 'Classique';
  static bool _isCreator = false;
  static List<Lobby> _lobbies = [];
  static String _gameId = 'initial-game-id';
  static bool _isCheatEnabled = false;
  static int _gameDuration = 0;
  late Lobby _lobby;
  static bool _isLobbyStarted = false;

  GameModes get gameModes => _gameModes;
  String get gameModesName => _gameModesName;
  bool get isCreator => _isCreator;
  List<Lobby> get lobbies => _lobbies;
  // String get gameId => _gameId;
  Lobby get lobby => _lobby;
  bool get isLobbyStarted => _isLobbyStarted;

  final SocketService socketService = Get.find();

  // New Lobby setters
  void setGameId(String newGameId) {
    print('Setting game id from $_gameId to $newGameId');
    _gameId = newGameId;
  }

  void setIsCheatEnabled(bool newIsCheatEnabled) {
    print('Setting isCheatEnabled from $_isCheatEnabled to $newIsCheatEnabled');
    _isCheatEnabled = newIsCheatEnabled;
  }

  void setGameDuration(int newGameDuration) {
    print('Setting game duration from $_gameDuration to $newGameDuration');
    _gameDuration = newGameDuration;
  }

  // Lobby Selection setters

  void setGameModes(GameModes newGameModes) {
    print('Setting game type to: $newGameModes');
    _gameModes = newGameModes;
    _gameModesName = isGameModesClassic() ? 'Classique' : 'Temps limité';
    print('Game type name is : $_gameModesName');
    notifyListeners();
  }

  void setIsCreator(bool newIsCreator) {
    print('Setting isCreator from $_isCreator to $newIsCreator');
    _isCreator = newIsCreator;
    notifyListeners();
  }

  bool isGameModesClassic() {
    return _gameModes == GameModes.Classic;
  }

  void createLobby() {
    print('Creating lobby');
    setIsCreator(true);
    Lobby lobbyCreated = Lobby(
      'initial-lobby-id', // Do not need send lobbyId
      _gameId, // Do not send gameId
      false, // isAvailable
      [], // players
      [], // observers
      _isCheatEnabled,
      isGameModesClassic() ? GameModes.Classic : GameModes.Limited,
      '', // Do not send password
      _gameDuration,
      ChatLog([], 'channel'), // Do not send chat log
      0, // TODO : Get nDifferences from the game
    );
    print('GameId Lobby Sent: ${lobbyCreated.gameId}');
    print('IsCheatEnabled Lobby Sent: ${lobbyCreated.isCheatEnabled}');
    print('Mode Lobby Sent: ${lobbyCreated.mode}');
    print('Time Lobby Sent: ${lobbyCreated.time}');
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Create.name,
      lobbyCreated.toJson(),
    );
    // _lobbies.add(Lobby());
    // notifyListeners();
  }

  void startLobby() {
    print('Starting lobby');
    _isLobbyStarted = true;
    print('_isLobbyStarted is now : $_isLobbyStarted');
    notifyListeners();
  }

  void endLobby() {
    print('Ending lobby');
    _isLobbyStarted = false;
    print('_isLobbyStarted is now : $_isLobbyStarted');
    notifyListeners();
  }

  void joinLobby(String joinedLobbyId) {
    print('Joining lobby with id: $joinedLobbyId');
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Join.name,
      joinedLobbyId,
    );
  }

  void setListeners() {
    socketService.on(SocketType.Lobby, LobbyEvents.Create.name, (data) {
      print('Lobbies received from LobbyEvents.Create : $data');
      if (data is Map<String, dynamic>) {
        Lobby lobbyCreated = Lobby.fromJson(data);
        print('LobbyId: ${lobbyCreated.lobbyId}');
        print('GameId: ${lobbyCreated.gameId}');
        print('IsAvailable: ${lobbyCreated.isAvailable}');
        print('Players: ${lobbyCreated.players}');
        print('Observers: ${lobbyCreated.observers}');
        print('IsCheatEnabled: ${lobbyCreated.isCheatEnabled}');
        print('Mode: ${lobbyCreated.mode}');
        print('Time: ${lobbyCreated.time}');
        print('Password: ${lobbyCreated.password}');
        print('ChatLog: ${lobbyCreated.chatLog}');
        print('NDifferences: ${lobbyCreated.nDifferences}');
        _lobby = lobbyCreated;
        notifyListeners();
      } else {
        print('Received data is not a Map<String, dynamic>');
      }
    });

    socketService.on(SocketType.Lobby, LobbyEvents.UpdateLobbys.name, (data) {
      print('Lobbies were updated');
      print('Lobbies received from LobbyEvents.UpdateLobbys : $data');
      if (data is List) {
        List<Lobby> updatedLobbies = data.map<Lobby>((lobbyData) {
          return Lobby.fromJson(lobbyData as Map<String, dynamic>);
        }).toList();
        print('Number of lobbies updated: ${updatedLobbies.length}');
        _lobbies = updatedLobbies;
        notifyListeners();
      } else {
        print('Received data is not a List');
      }
    });

    socketService.on(SocketType.Lobby, LobbyEvents.Start.name, (data) {
      print('Lobby with id $data was started');
      String startedLobbyId = data as String;
      if (startedLobbyId == _lobby.lobbyId) {
        startLobby();
      }
    });
  }
}
