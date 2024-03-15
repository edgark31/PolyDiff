import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/socket_service.dart';

class LobbyService extends ChangeNotifier {
  static GameModes _gameModes = GameModes.Classic;
  static bool _isCreator = false;
  static List<Lobby> _lobbies = [];
  late Lobby _lobby;
  static bool _isLobbyStarted = false;

  GameModes get gameModes => _gameModes;
  bool get isCreator => _isCreator;
  List<Lobby> get lobbies => _lobbies;
  Lobby get lobby => _lobby;
  bool get isLobbyStarted => _isLobbyStarted;

  final SocketService socketService = Get.find();
  final LobbySelectionService lobbySelectionService = Get.find();

  // Lobby Selection setters
  void setGameModes(GameModes newGameModes) {
    print('Setting game type to: $newGameModes');
    _gameModes = newGameModes;
    notifyListeners();
  }

  void setIsCreator(bool newIsCreator) {
    print('Setting isCreator from $_isCreator to $newIsCreator');
    _isCreator = newIsCreator;
    notifyListeners();
  }

  void createLobby() {
    setIsCreator(true);
    Lobby lobbyCreated = lobbySelectionService.createLobby(_gameModes);
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Create.name,
      lobbyCreated.toJson(),
    );
  }

  void startLobby() {
    setIsCreator(false);
    print('Starting lobby and telling the server');
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

  void joinLobby(String? joinedLobbyId) {
    setIsCreator(false);
    if (joinedLobbyId == null) {
      print('No joined lobby id was provided (!)');
      return;
    }
    _lobby = getLobbyFromLobbies();
    notifyListeners();
    print('Joining lobby with id: $joinedLobbyId');
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Join.name,
      {
        'lobbyId': joinedLobbyId,
        'password': null, // mobile can't create password lobbies
      },
    );
  }

  void leaveLobby() {
    String? leftLobbyId = _lobby.lobbyId;
    if (leftLobbyId == null) {
      print('No left lobby id was provided (!)');
      return;
    }
    print('Leaving lobby with id: $leftLobbyId');
    setIsCreator(false);
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Leave.name,
      leftLobbyId,
    );
    socketService.disconnect(SocketType.Lobby);
  }

  void endLobby() {
    print('Ending lobby');
    _isLobbyStarted = false;
    print('_isLobbyStarted is now : $_isLobbyStarted');
    notifyListeners();
    socketService.disconnect(SocketType.Lobby);
  }

  void setListeners() {
    // socketService.on(SocketType.Lobby, LobbyEvents.Create.name, (data) {
    //   print('Lobbies received from LobbyEvents.Create : $data');
    //   Lobby lobbyCreated = Lobby.fromJson(data as Map<String, dynamic>);
    //   _lobby = lobbyCreated;
    //   notifyListeners();
    // });

    socketService.on(SocketType.Lobby, LobbyEvents.UpdateLobbys.name, (data) {
      print('Lobbies received from LobbyEvents.UpdateLobbys : $data');
      List<Lobby> updatedLobbies = (data as List).map<Lobby>((lobbyData) {
        return Lobby.fromJson(lobbyData as Map<String, dynamic>);
      }).toList();
      print('Number of lobbies updated: ${updatedLobbies.length}');
      _lobbies = updatedLobbies;
      // TODO : fix error if creator leaves on waiting player
      if (isCurrentLobbyInLobbies()) {
        _lobby = getLobbyFromLobbies();
      }
      notifyListeners();
    });

    socketService.on(SocketType.Lobby, LobbyEvents.Start.name, (data) {
      // Lobby the client was waiting in was started
      print('Lobby with id $data was started');
      String startedLobbyId = data as String;
      if (startedLobbyId == _lobby.lobbyId) {
        // startLobby();
        _isLobbyStarted = true;
        print('_isLobbyStarted is now : $_isLobbyStarted');
        notifyListeners();
      }
    });

    // TODO: Implement LobbyEvents.Join Listerners ??
    // socketService.on(SocketType.Lobby, LobbyEvents.Join.name, (data) {

    // TODO: Implement LobbyEvents.Leave Listerners to handle creator quitting
    // socketService.on(SocketType.Lobby, LobbyEvents.Leave.name, (data) {
  }

  bool isGameModesClassic() {
    return _gameModes == GameModes.Classic;
  }

  bool isCurrentLobbyInLobbies() {
    return _lobbies.any((lobby) => lobby.lobbyId == _lobby.lobbyId);
  }

  Lobby getLobbyFromLobbies() {
    return _lobbies.firstWhere((lobby) => lobby.lobbyId == _lobby.lobbyId);
  }

  List<Lobby> filterLobbies() {
    return _lobbies
        .where((lobby) =>
            lobby.mode == _gameModes &&
            lobby.players.isNotEmpty &&
            lobby.password ==
                null) // Password lobbies are not displayed on mobile
        .toList();
  }
}
