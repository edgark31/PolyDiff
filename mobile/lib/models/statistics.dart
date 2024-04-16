class Statistics {
  int gamesPlayed;
  int gameWon;
  double averageTime;
  double averageDifferences;

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
      averageDifferences: json['averageDifferences'].toDouble(),
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
