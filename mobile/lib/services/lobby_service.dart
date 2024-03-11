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

  GameType get gameType => _gameType;
  String get gameTypeName => _gameTypeName;
  bool get isCreator => _isCreator;
  List<Lobby> get lobbies => _lobbies;
  // String get gameId => _gameId;

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
    setIsCreator(true);
    print('Creating lobby');
    // _lobbies.add(Lobby());
    // notifyListeners();
  }

  void startLobby() {
    // _lobbies.add(Lobby());
    // notifyListeners();
  }

  // void setListeners() {
  //   socketService.on

  //   void addPlayer(Player player) {
  //   if (!isGameStarted &&
  //       players.length < 4 &&
  //       !players.any((p) => p.playerId == player.playerId)) {
  //     players = List.from(players)..add(player);
  //   } else {
  //     print("Lobby is full, game has started, or player already in lobby.");
  //   }
  // }

  // bool removePlayer(String playerId) {
  //   if (!isGameStarted) {
  //     try {
  //       final playerToRemove =
  //           players.firstWhere((player) => player.playerId == playerId);
  //       players.remove(playerToRemove);
  //       return true;
  //     } catch (e) {
  //       // No matching player found
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  // void startGame() {
  //   if (players.any((player) => player.playerId == creatorId) &&
  //       players.length >= 2 &&
  //       players.length <= 4) {
  //     isGameStarted = true;
  //     print("Game started with ${players.length} players!");
  //   } else {
  //     print("Cannot start game. Must have 2 to 4 players.");
  //   }
  // }

  // void addChatMessage(String message) {
  //   chatMessages = List.from(chatMessages)..add(message);
  // }
}
