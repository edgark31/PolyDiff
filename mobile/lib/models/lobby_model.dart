import 'package:mobile/models/models.dart';

class Lobby {
  String lobbyId;
  String gameId;
  bool isAvailable;
  List<Player> players;
  final List<Observers> observers;
  final bool isCheatEnabled;
  final GameModes mode;
  final String? password;
  ChatLog chatLog;
  final int nDifferences;

  Lobby(
    this.lobbyId,
    this.gameId,
    this.isAvailable,
    this.players,
    this.observers,
    this.isCheatEnabled,
    this.mode,
    this.password,
    this.chatLog,
    this.nDifferences,
  );

  static Lobby fromJson(Map<String, dynamic> json) {
    return Lobby(
      json['lobbyId'],
      json['gameId'],
      json['isAvailable'],
      json['players'].map<Player>((player) => Player.fromJson(player)).toList(),
      json['observers'],
      json['isCheatEnabled'],
      GameModes.values.firstWhere((element) => element.name == json['mode']),
      json['password'],
      ChatLog.fromJson(json['chatLog']),
      json['nDifferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lobbyId': lobbyId,
      'gameId': gameId,
      'isAvailable': isAvailable,
      'players': players.map((player) => player.toJson()).toList(),
      'observers': observers,
      'isCheatEnabled': isCheatEnabled,
      'mode': mode.name,
      'password': password,
      'chatLog': chatLog.toJson(),
      'nDifferences': nDifferences,
    };
  }
}
