import 'package:mobile/models/game.dart';

class GameRecord {
  final Game game;
  final String accountId;
  final String date;
  final String startTime;
  final String endTime;
  final int duration;
  final bool isCheatEnabled;
  final int timeLimit;
  final List<GameEvent> gameEvents;

  GameRecord({
    required this.accountId,
    required this.game,
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
      accountId: json['accountId'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      duration: json['duration'],
      isCheatEnabled: json['isCheatEnabled'],
      timeLimit: json['timeLimit'],
      gameEvents: (json['gameEvents'] as List)
          .map((e) => GameEvent.fromJson(e))
          .toList(),
    );
  }
}

class GameEvent {
  final String timestamp;
  final String username;
  final String gameEvent;
  final Coordinate? coordinates;
  final bool? isMainCanvas;

  GameEvent({
    required this.timestamp,
    required this.username,
    required this.gameEvent,
    this.coordinates,
    this.isMainCanvas,
  });

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    return GameEvent(
      timestamp: json['timestamp'],
      username: json['username'],
      gameEvent: json['gameEvent'],
      coordinates: json['coordinates'] != null
          ? Coordinate.fromJson(json['coordinates'])
          : null,
      isMainCanvas: json['isMainCanvas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'username': username,
      'gameEvent': gameEvent,
      'coordinates': coordinates?.toJson(),
      'isMainCanvas': isMainCanvas,
    };
  }
}
