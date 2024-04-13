import 'package:mobile/models/models.dart';

class GameRecord {
  final String date;
  final Game game;
  final List<String> accountIds;
  final List<Player> players;
  final List<Observer>? observers;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final bool isCheatEnabled;
  final int timeLimit;
  final List<GameEventData> gameEvents;

  GameRecord({
    required this.date,
    required this.accountIds,
    required this.game,
    required this.players,
    required this.observers,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.isCheatEnabled,
    required this.timeLimit,
    required this.gameEvents,
  });

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    final DateTime startTime =
        DateTime.fromMillisecondsSinceEpoch(json['startTime']);
    final DateTime endTime =
        DateTime.fromMillisecondsSinceEpoch(json['endTime']);
    return GameRecord(
      date: json['date'],
      accountIds: List<String>.from(json['accountIds'].map((x) => x)),
      game: Game.fromJson(json['game']),
      players:
          List<Player>.from(json['players'].map((x) => Player.fromJson(x))),
      observers: json["observers"] != null
          ? List<Observer>.from(
              json['observers'].map((x) => Observer.fromJson(x)))
          : null,
      startTime: startTime,
      endTime: endTime,
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
  final DateTime timestamp;
  final String? modified;
  final List<Player>? players;
  final List<Observer>? observers;
  final String gameEvent;
  final Coordinate? coordClic;
  final List<int>?
      remainingDifferenceIndex; // Only sent when a difference is found
  final bool? isMainCanvas;
  final int? time;

  GameEventData({
    this.accountId,
    this.username,
    required this.timestamp,
    this.modified,
    this.players,
    this.observers,
    required this.gameEvent,
    this.coordClic,
    this.remainingDifferenceIndex,
    this.isMainCanvas,
    this.time,
  });

  factory GameEventData.fromJson(Map<String, dynamic> json) {
    final DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
    return GameEventData(
      accountId: json['accountId'] ?? '',
      username: json['username'] ?? '',
      timestamp: timestamp,
      modified: json['modified'] ?? '',
      players: json['players'] != null
          ? List<Player>.from(json['players'].map((x) => Player.fromJson(x)))
          : null,
      observers: json['observers'] != null
          ? List<Observer>.from(
              json['observers'].map((x) => Observer.fromJson(x)))
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

class GameRecordCard {
  final String gameName;
  final String gameOriginalImage;
  final List<String?> playerNames;
  final String durationFormatted;
  final String date;

  GameRecordCard({
    required this.gameName,
    required this.gameOriginalImage,
    required this.playerNames,
    required this.durationFormatted,
    required this.date,
  });

  factory GameRecordCard.fromGameRecord(GameRecord record) {
    Duration duration = record.endTime.difference(record.startTime);
    return GameRecordCard(
      gameName: record.game.name,
      gameOriginalImage: record.game.original,
      playerNames: record.players.map((player) => player.name).toList(),
      durationFormatted: duration.inSeconds.toString(),
      date: record.date,
    );
  }
}
