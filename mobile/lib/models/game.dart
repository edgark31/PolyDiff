class Game {
  String lobbyId;
  String gameId;
  String name;
  String original;
  String modified;
  String? difficulty;
  List<List<Coordinate>>? differences;
  int? nDifferences;
  List<String>? playedGameIds;
  Game(
    this.lobbyId,
    this.gameId,
    this.name,
    this.original,
    this.modified,
    this.difficulty,
    this.differences,
    this.nDifferences,
    this.playedGameIds,
  );

  Game.initial()
      : this(
          '', // lobbyId
          '', // gameId
          '', // name
          '', // original
          '', // modified
          '', // difficulty
          [], // differences
          0, // nDifferences
          [], // playedGameIds
        );
  factory Game.fromJson(Map<String, dynamic> json) {
    List<String>? playedGameIds;
    if (json['playedGameIds'] != null) {
      playedGameIds = List<String>.from(json['playedGameIds'].map((x) => x));
    }
    return Game(
      json['lobbyId'],
      json['gameId'],
      json['name'],
      json['original'],
      json['modified'],
      json['difficulty'],
      List<List<Coordinate>>.from(json['differences'].map((x) =>
          List<Coordinate>.from(
              x.map((x) => Coordinate.fromJson(x)).toList()))),
      json['nDifferences'],
      playedGameIds,
    );
  }
  Map<String, dynamic> toJson() => {
        'lobbyId': lobbyId,
        'gameId': gameId,
        'name': name,
        'original': original,
        'modified': modified,
        'difficulty': difficulty,
        'differences': List<dynamic>.from(differences!
            .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        'nDifferences': nDifferences,
        'playedGameIds': List<dynamic>.from(playedGameIds!.map((x) => x)),
      };
}

class Differences {
  List<Coordinate> currentDifference;
  int differencesFound;

  Differences(
      {required this.currentDifference, required this.differencesFound});

  factory Differences.fromJson(Map<String, dynamic> json) => Differences(
        currentDifference: List<Coordinate>.from(
            json['currentDifference'].map((x) => Coordinate.fromJson(x))),
        differencesFound: json['differencesFound'],
      );

  Map<String, dynamic> toJson() => {
        'currentDifference':
            List<dynamic>.from(currentDifference.map((x) => x.toJson())),
        'differencesFound': differencesFound,
      };
}

class Coordinate {
  int x;
  int y;

// To test canvas coordinate validation
  Coordinate({required this.x, required this.y});
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coordinate && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
        x: json['x'],
        y: json['y'],
      );

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}
