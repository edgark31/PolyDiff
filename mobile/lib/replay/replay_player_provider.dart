import 'package:flutter/material.dart';
import 'package:mobile/models/observers_model.dart';
import 'package:mobile/models/players.dart';

class ReplayPlayerProvider extends ChangeNotifier {
  // Observers and Players
  List<Player> _playersData = [];
  int _nObservers = 0;

  // Getters
  List<Player> get players => _playersData;
  int get nObservers => _nObservers;

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

  void setNumberOfObservers(List<Observer>? observers) {
    if (observers != null) {
      _nObservers = observers.length;
    } else {
      _nObservers = 0;
    }
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

  void updateNumberOfObservers(int? nObservers) {
    if (nObservers != null) {
      _nObservers = nObservers;
    } else {
      _nObservers = 0;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _playersData = [];
    _nObservers = 0;
    super.dispose();
  }
}
