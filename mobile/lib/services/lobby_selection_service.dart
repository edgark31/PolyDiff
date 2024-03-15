import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/lobby_model.dart';

class LobbySelectionService extends ChangeNotifier {
  static String? _gameId;
  static int _gameDuration = 0;
  static bool _isCheatEnabled = false;

  void setGameId(String newGameId) {
    _gameId = newGameId;
  }

  void setIsCheatEnabled(bool newIsCheatEnabled) {
    _isCheatEnabled = newIsCheatEnabled;
  }

  void setGameDuration(int newGameDuration) {
    _gameDuration = newGameDuration;
  }

  Lobby createLobby(GameModes gameMode) {
    if (gameMode == GameModes.Limited) {
      _gameId = null; // Limited has no game id
    }
    return Lobby.create(
      gameId: _gameId,
      isCheatEnabled: _isCheatEnabled,
      mode: gameMode,
      time: _gameDuration,
      timeLimit: _gameDuration,
    );
  }
}
