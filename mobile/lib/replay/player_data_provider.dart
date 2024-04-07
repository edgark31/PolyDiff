import 'package:flutter/material.dart';
import 'package:mobile/models/players.dart';

class PlayersDataProvider extends ChangeNotifier {
  List<Player> _playersData = [];

  List<Player> get playersData => _playersData;

  void setPlayersData(List<Player> playersData) {
    _playersData = playersData;
    notifyListeners();
  }

  void updatePlayerData(Player playerData) {
    final index =
        _playersData.indexWhere((player) => player.name == player.name);
    if (index != -1) {
      _playersData[index] = playerData;
      notifyListeners();
    }
  }
}
