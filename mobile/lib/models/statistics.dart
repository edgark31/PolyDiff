class Statistics {
  int gamePlayed;
  int gameWon;
  double averageTime;
  int averageDifferences;

  Statistics({
    required this.gamePlayed,
    required this.gameWon,
    required this.averageTime,
    required this.averageDifferences,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      gamePlayed: json['gamePlayed'],
      gameWon: json['gameWon'],
      averageTime: json['averageTime'].toDouble(),
      averageDifferences: json['averageDifferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamePlayed': gamePlayed,
      'gameWon': gameWon,
      'averageTime': averageTime,
      'averageDifferences': averageDifferences,
    };
  }
}
