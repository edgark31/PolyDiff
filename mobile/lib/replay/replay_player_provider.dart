import 'package:flutter/material.dart';
import 'package:mobile/models/players.dart';

class ReplayPlayerProvider extends ChangeNotifier {
  // Observers and Players
  List<Player> _data = [];
  int _nObservers = 0;

  // Getters
  List<Player> get data => _data;
  int get nObservers => _nObservers;

  Player getPlayer(int index) {
    return _data[index];
  }

  void resetScore() {
    for (Player player in _data) {
      player.count = 0;
    }
    notifyListeners();
  }

  set initialPlayersData(List<Player> playersData) {
    _data = playersData;

    for (Player player in _data) {
      player.count = 0;
    }
  }

  set initialNumberOfObservers(int initialNumberOfObservers) {
    _nObservers = initialNumberOfObservers;
  }

  void updatePlayerData(Player playerData) {
    final index = _data.indexWhere((player) => playerData.name == player.name);
    if (index != -1) {
      _data[index] = playerData;
      print("updating player data for ${playerData.name}");
      notifyListeners();
    }
  }

  void updateNumberOfObservers(int? nObservers) {
    if (nObservers != null) {
      _nObservers = nObservers;
    } else {
      _nObservers = 0;
    }
    notifyListeners();
  }
}
