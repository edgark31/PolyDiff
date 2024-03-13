import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/socket_service.dart';

class LobbyService extends ChangeNotifier {
  static GameModes _gameModes = GameModes.Classic;
  static String _gameModesName = GameModes.Classic.name;
  static bool _isCreator = false;
  static List<Lobby> _lobbies = [];
  static String _gameId = 'initial-game-id';
  static bool _isCheatEnabled = false;
  static int _gameDuration = 0;
  late Lobby _lobby;
  static bool _isLobbyStarted = false;
  static bool _isPlayerInLobbyPage = false;

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
    _gameModesName =
        isGameModesClassic() ? GameModes.Classic.name : GameModes.Limited.name;
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
    Lobby lobbyCreated = Lobby.create(
      isAvailable: true,
      players: [],
      observers: [], // observers
      isCheatEnabled: _isCheatEnabled,
      mode: isGameModesClassic() ? GameModes.Classic : GameModes.Limited,
      time: _gameDuration,
      timeLimit: _gameDuration, // timeLimit
    );
    print('IsCheatEnabled Lobby Sent: ${lobbyCreated.isCheatEnabled}');
    print('Mode Lobby Sent: ${lobbyCreated.mode}');
    print('Time Lobby Sent: ${lobbyCreated.time}');
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Create.name,
      lobbyCreated.toJson(),
    );
    print('Setting _isPlayerInLobbyPage to true');
    _isPlayerInLobbyPage = true;
    // _lobbies.add(Lobby());
    // notifyListeners();
  }

  void startLobby() {
    print('Starting lobby and telling the server');
    setIsCreator(false);
    // _isLobbyStarted = true;
    // print('_isLobbyStarted is now : $_isLobbyStarted');
    // notifyListeners();
    String? startedLobbyId = _lobby.lobbyId;
    if (startedLobbyId == null) {
      print('No started lobby id was provided (!)');
      return;
    }
    print('Starting lobby with id: $startedLobbyId');
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Start.name,
      startedLobbyId,
    );
  }

  void endLobby() {
    print('Ending lobby');
    _isLobbyStarted = false;
    print('_isLobbyStarted is now : $_isLobbyStarted');
    notifyListeners();
    socketService.disconnect(SocketType.Lobby);
  }

  void joinLobby(String? joinedLobbyId) {
    if (joinedLobbyId == null) {
      print('No joined lobby id was provided (!)');
      return;
    }
    _lobby = _lobbies.firstWhere((lobby) => lobby.lobbyId == joinedLobbyId);
    print('Setting _isPlayerInLobbyPage to true');
    _isPlayerInLobbyPage = true;
    notifyListeners();
    print('Joining lobby with id: $joinedLobbyId');
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Join.name,
      {
        'lobbyId': joinedLobbyId,
        'password': null,
      },
    );
  }

  void leaveLobby() {
    String? leftLobbyId = _lobby.lobbyId;
    if (leftLobbyId == null) {
      print('No left lobby id was provided (!)');
      return;
    }
    print('Leaving lobby with id: ${leftLobbyId}');
    setIsCreator(false);
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Leave.name,
      leftLobbyId,
    );
    socketService.disconnect(SocketType.Lobby);
    print('Setting _isPlayerInLobbyPage to false');
    _isPlayerInLobbyPage = false;
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
        if (_isPlayerInLobbyPage) {
          print('Player is in lobby page, updating the main lobby');
          _lobby =
              _lobbies.firstWhere((lobby) => lobby.lobbyId == _lobby.lobbyId);
        }
        notifyListeners();
      } else {
        print('Received data is not a List');
      }
    });

    socketService.on(SocketType.Lobby, LobbyEvents.Start.name, (data) {
      // Lobby the client was waiting in was started
      print('Lobby with id $data was started');
      String startedLobbyId = data as String;
      if (startedLobbyId == _lobby.lobbyId) {
        // startLobby();
        _isLobbyStarted = true;
        print('_isLobbyStarted is now : $_isLobbyStarted');
        print('Setting _isPlayerInLobbyPage to false');
        _isPlayerInLobbyPage = false;
        notifyListeners();
      }
    });

    // TODO: Implement LobbyEvents.Join Listerners ??
    // socketService.on(SocketType.Lobby, LobbyEvents.Join.name, (data) {

    // TODO: Implement LobbyEvents.Leave Listerners to handle creator quitting
    // socketService.on(SocketType.Lobby, LobbyEvents.Leave.name, (data) {
  }
}
