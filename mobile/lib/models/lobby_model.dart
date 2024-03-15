import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';

class Lobby {
  String? lobbyId;
  String? gameId;
  Game? game;
  bool isAvailable;
  List<Player> players;
  final List<Observers> observers;
  final bool isCheatEnabled;
  final GameModes mode;
  final String? password;
  int? time;
  int timeLimit;
  int? bonusTime;
  ChatLog? chatLog;
  int? nDifferences;

  Lobby(
    this.lobbyId,
    this.gameId,
    this.game,
    this.isAvailable,
    this.players,
    this.observers,
    this.isCheatEnabled,
    this.mode,
    this.password,
    this.time,
    this.timeLimit,
    this.bonusTime,
    this.chatLog,
    this.nDifferences,
  );

  // Method to create a new lobby
  Lobby.create({
    required String? gameId,
    required bool isCheatEnabled,
    required GameModes mode,
    required int time,
    required int timeLimit,
  }) : this(
          null, // lobbyId
          gameId, // gameId
          null, // game
          true, // isAvailable : initial lobby is available
          [], // players : initial lobby has no players
          [], // observers : initial lobby has no observers
          isCheatEnabled,
          mode,
          null, // password
          time, // time
          timeLimit,
          null, // bonusTime
          null, // chatLog
          null, // nDifferences
        );

  Lobby.initial()
      : this(
          null, // lobbyId
          null, // gameId
          null, // game
          false, // isAvailable
          [], // players
          [], // observers
          false, // isCheatEnabled
          GameModes.Classic, // mode
          null, // password
          0, // time
          0, // timeLimit
          null, // bonusTime
          null, // chatLog
          null, // nDifferences
        );

  static Lobby fromJson(Map<String, dynamic> json) {
    if (json['observers'] == []) {
      json['observers'] = List<Observers>.empty();
    }
    if (json['players'] == []) {
      json['players'] = List<Player>.empty();
    }
    Game? game = json['game'] != null ? Game.fromJson(json['game']) : null;
    return Lobby(
      json['lobbyId'],
      json['gameId'],
      game,
      json['isAvailable'],
      json['players'].map<Player>((player) => Player.fromJson(player)).toList(),
      json['observers']
          .map<Observers>((observers) => Observers.fromJson(observers))
          .toList(),
      json['isCheatEnabled'],
      GameModes.values.firstWhere((element) => element.name == json['mode']),
      json['password'],
      json['time'],
      json['timeLimit'],
      json['bonusTime'],
      ChatLog.fromJson(json['chatLog']),
      json['nDifferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lobbyId': lobbyId,
      'gameId': gameId,
      'game': game?.toJson(),
      'isAvailable': isAvailable,
      'players': players.map((player) => player.toJson()).toList(),
      'observers': observers.map((observer) => observer.toJson()).toList(),
      'isCheatEnabled': isCheatEnabled,
      'mode': mode.name,
      'password': password,
      'time': time,
      'timeLimit': timeLimit,
      'bonusTime': bonusTime,
      'chatLog': chatLog?.toJson(),
      'nDifferences': nDifferences,
    };
  }
}
