import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/socket_service.dart';

class LobbyService extends ChangeNotifier {
  static GameType _gameType = GameType.Classic;
  static String _gameTypeName = 'Classique';
  static bool _isCreator = false;
  static List<Lobby> _lobbies = [];
  static String _gameId = 'initial-game-id';
  static bool _isCheatEnabled = false;
  static int _gameDuration = 0;
  late Lobby _lobby;
  static bool _isLobbyStarted = false;

  GameType get gameType => _gameType;
  String get gameTypeName => _gameTypeName;
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

  void setGameType(GameType gameType) {
    print('Setting game type to: $gameType');
    _gameType = gameType;
    _gameTypeName = isGameTypeClassic() ? 'Classique' : 'Temps limité';
    print('Game type name is : $_gameTypeName');
    notifyListeners();
  }

  void setIsCreator(bool newIsCreator) {
    print('Setting isCreator from $_isCreator to $newIsCreator');
    _isCreator = newIsCreator;
    notifyListeners();
  }

  bool isGameTypeClassic() {
    return _gameType == GameType.Classic;
  }

  void createLobby() {
    print('Creating lobby');
    setIsCreator(true);
    Lobby lobbyCreated = Lobby(
      'initial-lobby-id', // Do not send lobbyId
      _gameId, /// Do not send gameId
      false,
      [],
      [],
      _isCheatEnabled,
      _gameType == GameType.Classic ? 'classic' : 'limited',
      '',
      ChatLog([], 'channel'), // Do not send chat log
      0, // TODO : Get this from the game
    );
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
      if (data is Map<String, dynamic>) {
        print(
            'Lobbies received from LobbyEvents.UpdateLobbys : $data'); // TODO: Check structure of received data
        List<Lobby> updatedLobbies = data['lobbies']
            .map<Lobby>((lobby) => Lobby.fromJson(lobby))
            .toList(); // TODO: Check if this works
        print('nlobbies LobbyEvents.Create : ${updatedLobbies.length}');
        _lobbies = updatedLobbies;
        notifyListeners();
      } else {
        print('Received data is not a Map<String, dynamic>');
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
