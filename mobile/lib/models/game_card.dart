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
  List<String> playerUsernames;

  GameCard({
    required this.name,
    required this.gameId,
    required this.gameMode,
    required this.nDifferences,
    required this.numbersOfPlayers,
    required this.thumbnail,
    required this.playerUsernames,
  });

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      name: json['name'] as String,
      gameId: json['_id'] as String,
      gameMode: GameMode.classic, // TODO: Maybe change in future
      nDifferences: 0, // TODO: Get this info from the server, for now it's '0
      numbersOfPlayers: 2, // TODO: Get this info from lobbyservice
      thumbnail: json['thumbnail'] as String,
      playerUsernames: [], // TODO: Get this info from lobbyservice
    );
  }
}
