import 'package:mobile/models/players.dart';

class GameSession {
  String gameSessionId;
  String startTime;
  List<GameAction> actions;
  List<Player> players;
  String endTime;

  GameSession({
    required this.gameSessionId,
    required this.startTime,
    required this.actions,
    required this.players,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'gameSessionId': gameSessionId,
        'startTime': startTime,
        'actions': actions.map((x) => x.toJson()).toList(),
        'players': players.map((x) => x.toJson()).toList(),
        'endTime': endTime,
      };
}

class GameAction {
  String type;
  String timestamp;
  Map<String, dynamic> details;

  GameAction({
    required this.type,
    required this.timestamp,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'timestamp': timestamp,
        'details': details,
      };
}
