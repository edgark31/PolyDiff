class GameHistory {
  String date;
  String startingHour;
  int duration;
  String gameMode;
  PlayerInfo player1;
  PlayerInfo? player2;

  GameHistory({
    required this.date,
    required this.startingHour,
    required this.duration,
    required this.gameMode,
    required this.player1,
    this.player2,
  });

  factory GameHistory.fromJson(Map<String, dynamic> json) => GameHistory(
        date: json['date'],
        startingHour: json['startingHour'],
        duration: json['duration'],
        gameMode: json['gameMode'],
        player1: PlayerInfo.fromJson(json['player1']),
        player2: json['player2'] != null
            ? PlayerInfo.fromJson(json['player2'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'startingHour': startingHour,
        'duration': duration,
        'gameMode': gameMode,
        'player1': player1.toJson(),
        'player2': player2?.toJson(),
      };
}

class PlayerInfo {
  String name;
  bool isWinner;
  bool isQuitter;

  PlayerInfo(
      {required this.name, required this.isWinner, required this.isQuitter});

  factory PlayerInfo.fromJson(Map<String, dynamic> json) => PlayerInfo(
        name: json['name'],
        isWinner: json['isWinner'],
        isQuitter: json['isQuitter'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'isWinner': isWinner,
        'isQuitter': isQuitter,
      };
}
