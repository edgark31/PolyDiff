import 'package:mobile/models/game.dart';
import 'package:mobile/models/players.dart';

class GameRecord {
  final Game game;
  final List<Player> players;
  final List<String> accountIds;
  final String date;
  final int startTime;
  final int endTime;
  final int duration;
  final bool isCheatEnabled;
  final int timeLimit;
  final List<GameEventData> gameEvents;

  GameRecord({
    required this.game,
    required this.players,
    required this.accountIds,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.isCheatEnabled,
    required this.timeLimit,
    required this.gameEvents,
  });

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      game: Game.fromJson(json['game']),
      players:
          List<Player>.from(json['players'].map((x) => Player.fromJson(x))),
      accountIds: List<String>.from(json['accountIds'].map((x) => x)),
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      duration: json['duration'],
      isCheatEnabled: json['isCheatEnabled'],
      timeLimit: json['timeLimit'],
      gameEvents: List<GameEventData>.from(
          json['gameEvents'].map((x) => GameEventData.fromJson(x))),
    );
  }
}

class GameEventData {
  final int? timestamp;
  final String username;
  final String? accountId;
  final List<Player>? players;
  final String gameEvent;
  final Coordinate? coordClic;
  final List<int>? remainingDifferenceIndex;
  final bool? isMainCanvas;

  GameEventData({
    this.timestamp,
    required this.username,
    this.accountId,
    this.players,
    required this.gameEvent,
    this.coordClic,
    this.remainingDifferenceIndex,
    this.isMainCanvas,
  });

  factory GameEventData.fromJson(Map<String, dynamic> json) {
    return GameEventData(
      timestamp: json['timestamp'],
      username: json['username'],
      accountId: json['accountId'],
      players: json['players'] != null
          ? List<Player>.from(json['players'].map((x) => Player.fromJson(x)))
          : null,
      gameEvent: json['gameEvent'],
      coordClic: json['coordClic'] != null
          ? Coordinate.fromJson(json['coordClic'])
          : null,
      remainingDifferenceIndex: json['remainingDifferenceIndex'] != null
          ? List<int>.from(json['remainingDifferenceIndex'])
          : null,
      isMainCanvas: json['isMainCanvas'],
    );
  }
}
