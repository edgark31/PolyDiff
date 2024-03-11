import 'package:mobile/constants/enums.dart';
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
  int time;
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
    this.time,
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
      json['time'],
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
      'time': time,
      'chatLog': chatLog.toJson(),
      'nDifferences': nDifferences,
    };
  }
}
