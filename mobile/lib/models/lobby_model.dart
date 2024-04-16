import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';

class Lobby {
  String? lobbyId;
  String? gameId;
  bool isAvailable;
  List<Player> players;
  final List<Observer> observers;
  final bool isCheatEnabled;
  final GameModes mode;
  final String? password;
  int? time;
  int timeLimit;
  int? bonusTime;
  int timePlayed;
  ChatLog? chatLog;
  int? nDifferences;

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
    this.timeLimit,
    this.bonusTime,
    this.timePlayed,
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
    required int? bonusTime,
    required int? nDifferences,
  }) : this(
          null, // lobbyId
          gameId, // gameId
          true, // isAvailable : initial lobby is available
          [], // players : initial lobby has no players
          [], // observers : initial lobby has no observers
          isCheatEnabled,
          mode,
          null, // password
          time, // time
          timeLimit,
          bonusTime, // bonusTime
          0, // timePlayed
          null, // chatLog
          nDifferences,
        );

  Lobby.initial()
      : this(
          null, // lobbyId
          null, // gameId
          false, // isAvailable
          [], // players
          [], // observers
          false, // isCheatEnabled
          GameModes.Classic, // mode
          null, // password
          0, // time
          0, // timeLimit
          null, // bonusTime
          0, // timePlayed
          null, // chatLog
          null, // nDifferences
        );

  static Lobby fromJson(Map<String, dynamic> json) {
    if (json['observers'] == []) {
      json['observers'] = List<Observer>.empty();
    }
    if (json['players'] == []) {
      json['players'] = List<Player>.empty();
    }
    return Lobby(
      json['lobbyId'],
      json['gameId'],
      json['isAvailable'],
      json['players'].map<Player>((player) => Player.fromJson(player)).toList(),
      json['observers']
          .map<Observer>((observers) => Observer.fromJson(observers))
          .toList(),
      json['isCheatEnabled'],
      GameModes.values.firstWhere((element) => element.name == json['mode']),
      json['password'],
      json['time'],
      json['timeLimit'],
      json['bonusTime'],
      json['timePlayed'],
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
      'observers': observers.map((observer) => observer.toJson()).toList(),
      'isCheatEnabled': isCheatEnabled,
      'mode': mode.name,
      'password': password,
      'time': time,
      'timeLimit': timeLimit,
      'bonusTime': bonusTime,
      'timePlayed': timePlayed,
      'chatLog': chatLog?.toJson(),
      'nDifferences': nDifferences,
    };
  }
}
