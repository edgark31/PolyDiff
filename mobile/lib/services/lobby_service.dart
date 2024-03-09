import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';

class LobbyService extends ChangeNotifier {
  static GameType _gameType = GameType.Classic;
  static String _gameTypeName = 'Classique';

  GameType get gameType => _gameType;
  String get gameTypeName => _gameTypeName;

  void setGameType(GameType gameType) {
    print('Setting game type to: $gameType');
    _gameType = gameType;
    _gameTypeName = isGameTypeClassic() ? 'Classique' : 'Temps limité';
    print('Game type name is : $_gameTypeName');
    notifyListeners();
  }

  bool isGameTypeClassic() {
    return _gameType == GameType.Classic;
  }
}
