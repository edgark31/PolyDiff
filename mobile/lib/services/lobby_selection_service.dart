import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/lobby_model.dart';

class LobbySelectionService extends ChangeNotifier {
  static String? _gameId;
  static int _gameDuration = 0;
  static int? _gameBonus;
  static bool _isCheatEnabled = false;
  static int? _nDifferences;

  void setGameId(String newGameId) {
    _gameId = newGameId;
  }

  void setIsCheatEnabled(bool newIsCheatEnabled) {
    _isCheatEnabled = newIsCheatEnabled;
  }

  void setNDifferences(int? newNDifferences) {
    _nDifferences = newNDifferences;
  }

  void setGameDuration(int newGameDuration) {
    _gameDuration = newGameDuration;
  }

  void setGameBonus(int newGameBonus) {
    _gameBonus = newGameBonus;
  }

  Lobby createLobby(GameModes gameMode) {
    if (gameMode == GameModes.Limited) {
      _gameId = null; // Limited has no game id
      _nDifferences = null; // Limited has no differences
    }
    if (gameMode == GameModes.Classic) {
      _gameBonus = null; // Classic has no bonus
    }
    if (gameMode == GameModes.Practice) {
      _gameBonus = null; // Practice has no bonus
      _isCheatEnabled = false; // Practice has no cheat
      _gameDuration = 0; // Practice has no time limit
    }

    return Lobby.create(
      gameId: _gameId,
      isCheatEnabled: _isCheatEnabled,
      mode: gameMode,
      time: _gameDuration,
      timeLimit: _gameDuration,
      bonusTime: _gameBonus,
      nDifferences: _nDifferences,
    );
  }
}
