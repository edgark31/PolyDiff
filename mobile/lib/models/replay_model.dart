import 'package:mobile/constants/enums.dart';

class ReplayEvent {
  final GameEvents action;
  final int timestamp;
  final dynamic data;

  ReplayEvent({required this.action, required this.timestamp, this.data});
}

class Replay {
  final String gameId;
  final List<ReplayEvent> events;

  Replay({required this.gameId, required this.events});
}
