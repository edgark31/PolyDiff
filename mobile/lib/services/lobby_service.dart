import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';

class LobbyService extends ChangeNotifier {
  static GameType _gameType = GameType.Classic;
  static String _gameTypeName = 'Classique';
  static bool _isCreator = false;

  GameType get gameType => _gameType;
  String get gameTypeName => _gameTypeName;
  bool get isCreator => _isCreator;

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
}
