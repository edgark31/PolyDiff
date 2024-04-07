import 'package:mobile/models/game.dart';
import 'package:mobile/models/players.dart';

class GameRecord {
  final String date;
  final Game game;
  final List<Player> players;
  final List<String>? accountIds;
  final int startTime;
  final int endTime;
  final int duration;
  final bool isCheatEnabled;
  final int timeLimit;
  final List<GameEventData> gameEvents;

  GameRecord({
    required this.date,
    this.accountIds,
    required this.game,
    required this.players,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.isCheatEnabled,
    required this.timeLimit,
    required this.gameEvents,
  });

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      date: json['date'],
      accountIds: json['accountIds'] != null
          ? List<String>.from(json['accountIds'].map((x) => x))
          : null,
      game: Game.fromJson(json['game']),
      players:
          List<Player>.from(json['players'].map((x) => Player.fromJson(x))),
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
  final String? accountId;
  final String? username;
  final int? timestamp;
  final List<Player>? players;
  final String gameEvent;
  final Coordinate? coordClic;
  final List<int>?
      remainingDifferenceIndex; // Only sent when a difference is found
  final bool? isMainCanvas;
  final int? time;

  GameEventData({
    this.timestamp,
    this.username,
    this.accountId,
    this.players,
    required this.gameEvent,
    this.coordClic,
    this.remainingDifferenceIndex,
    this.isMainCanvas,
    this.time,
  });

  factory GameEventData.fromJson(Map<String, dynamic> json) {
    return GameEventData(
      timestamp: json['timestamp'] ?? 0,
      username: json['username'] ?? '',
      accountId: json['accountId'] ?? '',
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
      isMainCanvas: json['isMainCanvas'] ?? false,
      time: json['time'] ?? 0,
    );
  }
}
