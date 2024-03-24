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
  static Lobby _lobby = Lobby.initial();

  GameModes get gameModes => _gameModes;
  bool get isCreator => _isCreator;
  List<Lobby> get lobbies => _lobbies;
  Lobby get lobby => _lobby;

  final SocketService socketService = Get.find();
  final LobbySelectionService lobbySelectionService = Get.find();

  void setGameModes(GameModes newGameModes) {
    _gameModes = newGameModes;
    notifyListeners();
  }

  void setIsCreator(bool newIsCreator) {
    _isCreator = newIsCreator;
    notifyListeners();
  }

  void setLobby(Lobby newLobby) {
    _lobby = newLobby;
    notifyListeners();
  }

  void createLobby() {
    setIsCreator(true);
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Create.name,
      lobbySelectionService.createLobby(_gameModes).toJson(),
    );
  }

  void startLobby() {
    // setIsCreator(false);
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Start.name,
      _lobby.lobbyId,
    );
  }

  void joinLobby(String? joinedLobbyId) {
    setIsCreator(false);
    setLobby(getLobbyFromLobbies(joinedLobbyId));
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Join.name,
      {
        'lobbyId': joinedLobbyId,
        'password': null, // mobile can't see or join password lobbies
      },
    );
  }

  void leaveLobby() {
    setIsCreator(false);
    socketService.send(
      SocketType.Lobby,
      LobbyEvents.Leave.name,
      _lobby.lobbyId,
    );
    setLobby(Lobby.initial());
    endLobby();
  }

  void endLobby() {
    socketService.disconnect(SocketType.Lobby);
  }

  void setupLobby(GameModes mode) {
    setListeners();
    setGameModes(mode);
  }

  void setListeners() {
    socketService.on(SocketType.Lobby, LobbyEvents.Create.name, (data) {
      setLobby(Lobby.fromJson(data as Map<String, dynamic>));
    });

    socketService.on(SocketType.Lobby, LobbyEvents.UpdateLobbys.name, (data) {
      print('Lobbies received from LobbyEvents.UpdateLobbys : $data');
      _lobbies = (data as List).map<Lobby>((lobbyData) {
        return Lobby.fromJson(lobbyData as Map<String, dynamic>);
      }).toList();
      if (isCurrentLobbyInLobbies()) {
        _lobby = getLobbyFromLobbies(_lobby.lobbyId);
      }
      notifyListeners();
    });

    // TODO: Implement LobbyEvents.Start Listeners ??
    // socketService.on(SocketType.Lobby, LobbyEvents.Start.name, (data) {
    //   if ((data as String) == _lobby.lobbyId) {
    //     _isLobbyStarted = true;
    //     notifyListeners();
    //   }
    // });

    // TODO: Implement LobbyEvents.Join Listeners ??
    // socketService.on(SocketType.Lobby, LobbyEvents.Join.name, (data) {

    // TODO: Implement LobbyEvents.Leave Listeners to handle creator quitting
    // socketService.on(SocketType.Lobby, LobbyEvents.Leave.name, (data) {
  }

  bool isGameModesClassic() {
    return _gameModes == GameModes.Classic;
  }

  bool isCurrentLobbyStarted() {
    return _lobby.isAvailable == false;
  }

  bool isCurrentLobbyInLobbies() {
    return _lobbies.any((lobby) => lobby.lobbyId == _lobby.lobbyId);
  }

  Lobby getLobbyFromLobbies(String? lobbyId) {
    return _lobbies.firstWhere((lobby) => lobby.lobbyId == lobbyId);
  }

  List<Lobby> filterLobbies() {
    return _lobbies
        .where((lobby) =>
            lobby.mode == _gameModes &&
            lobby.players.isNotEmpty &&
            doesLobbyHavePassword()) // Password lobbies are not displayed on mobile
        .toList();
  }

  bool doesLobbyHavePassword() {
    return lobby.password == null || lobby.password == ''; // Password lobbies are not displayed on mobile
  }
}
