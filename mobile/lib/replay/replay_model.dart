import 'package:mobile/constants/enums.dart';

class ReplayGameEvent {
  final GameEvent action;
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
                action: GameEvent.values
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
