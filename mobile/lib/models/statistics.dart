class Statistics {
  int gamesPlayed;
  int gameWon;
  double averageTime;
  int averageDifferences;

  Statistics({
    required this.gamesPlayed,
    required this.gameWon,
    required this.averageTime,
    required this.averageDifferences,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      gamesPlayed: json['gamesPlayed'],
      gameWon: json['gameWon'],
      averageTime: json['averageTime'].toDouble(),
      averageDifferences: json['averageDifferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gameWon': gameWon,
      'averageTime': averageTime,
      'averageDifferences': averageDifferences,
    };
  }
}
