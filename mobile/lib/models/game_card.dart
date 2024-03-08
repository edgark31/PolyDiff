enum GameMode {
  practice,
  classic,
  limitedTime,
}

GameMode gameModeFromString(String modeString) {
  return GameMode.values.firstWhere(
    (mode) => mode.toString().split('.').last == modeString,
    orElse: () => GameMode.practice, // Default value
  );
}

class GameCard {
  String name;
  String gameId;
  GameMode gameMode;
  int nDifferences;
  String thumbnail;
  // TODO: get this info from with the lobby service
  int numbersOfPlayers;

  GameCard({
    required this.name,
    required this.gameId,
    required this.gameMode,
    required this.nDifferences,
    required this.numbersOfPlayers,
    required this.thumbnail,
  });

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      name: json['name'],
      gameId: json['gameId'],
      gameMode: gameModeFromString(json['gameMode']),
      nDifferences: json['nDifferences'],
      numbersOfPlayers: json['numberOfPlayers'] ?? 0,
      thumbnail: json['thumbnail'],
    );
  }
}
