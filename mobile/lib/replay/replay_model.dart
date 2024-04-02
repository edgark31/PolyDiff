import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/game.dart';
import 'package:mobile/models/players.dart';

class ReplayGameEvent {
  final GameEvents action;
  final int timestamp;
  final dynamic data;

  ReplayGameEvent({required this.action, required this.timestamp, this.data});
}

class Replay {
  final String gameId;
  final List<ReplayGameEvent> events;

  Replay({required this.gameId, required this.events});

  factory Replay.fromJson(Map<String, dynamic> json) {
    final List<dynamic> events = json['events'];
    return Replay(
      gameId: json['gameId'],
      events: events
          .map((event) => ReplayGameEvent(
                action: GameEvents.values
                    .firstWhere((element) => element == event['event']),
                timestamp: event['timestamp'],
                data: event['data'],
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'events': events
          .map((event) => {
                'event': event.action,
                'timestamp': event.timestamp,
                'data': event.data,
              })
          .toList(),
    };
  }

  Replay copyWith({
    String? gameId,
    List<ReplayGameEvent>? events,
  }) {
    return Replay(
      gameId: gameId ?? this.gameId,
      events: events ?? this.events,
    );
  }

  @override
  String toString() => 'Replay(gameId: $gameId, events: $events)';
}

class GameEventData {
  final int? timestamp;
  final String username;
  final String? accountId;
  final List<Player>? players;
  final String gameEvent;
  final Coordinate? coordClic;
  final bool? isMainCanvas;

  GameEventData({
    this.timestamp,
    required this.username,
    this.accountId,
    this.players,
    required this.gameEvent,
    this.coordClic,
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
      isMainCanvas: json['isMainCanvas'],
    );
  }
}
