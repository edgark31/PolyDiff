import 'package:flutter/material.dart';

class PlayerDataProvider extends ChangeNotifier {
  String _playerName = '';
  String _playerId = '';
  String _playerAvatar = '';
  int _playerScore = 0;

  String get playerName => _playerName;
  String get playerId => _playerId;
  String get playerAvatar => _playerAvatar;
  int get playerScore => _playerScore;

  void setPlayerName(String newPlayerName) {
    _playerName = newPlayerName;
    notifyListeners();
  }

  void setPlayerId(String newPlayerId) {
    _playerId = newPlayerId;
    notifyListeners();
  }

  void setPlayerAvatar(String newPlayerAvatar) {
    _playerAvatar = newPlayerAvatar;
    notifyListeners();
  }

  void setPlayerScore(int newPlayerScore) {
    _playerScore = newPlayerScore;
    notifyListeners();
  }
}
