import 'package:flutter/material.dart';
import 'package:mobile/models/players.dart';

class ReplayPlayerProvider extends ChangeNotifier {
  List<Player> _playersData = [];

  List<Player> get players => _playersData;

  Player getPlayer(int index) {
    return _playersData[index];
  }

  void resetScore() {
    for (Player player in _playersData) {
      player.count = 0;
    }
  }

  void setPlayersData(List<Player> playersData) {
    _playersData = playersData;
    notifyListeners();
  }

  void updatePlayerData(Player playerData) {
    final index =
        _playersData.indexWhere((player) => playerData.name == player.name);
    if (index != -1) {
      _playersData[index] = playerData;
      print("updating player data for ${playerData.name}");
      notifyListeners();
    }
  }
}
