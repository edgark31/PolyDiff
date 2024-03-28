class ReplayGame {
  String lobbyId;
  String gameId;
  String name;
  String original;
  String modified;
  String? difficulty;
  List<Difference>? differences;
  int? nDifferences;
  List<String>? playedGameIds;
  ReplayGame(
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

  ReplayGame.initial()
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
  factory ReplayGame.fromJson(Map<String, dynamic> json) {
    List<String>? playedGameIds = json['playedGameIds'] != null
        ? List<String>.from(json['playedGameIds'].map((x) => x))
        : [];

    List<Difference>? differences = json['differences'] != null
        ? json['differences']
            .map<Difference>((x) => Difference.fromJson(x))
            .toList()
        : [];

    return ReplayGame(
      json['lobbyId'],
      json['gameId'],
      json['name'],
      json['original'],
      json['modified'],
      json['difficulty'],
      differences,
      json['nDifferences'],
      playedGameIds,
    );
  }
}

class Difference {
  List<Coordinate> coordinates;
  bool isFound;

  Difference({required this.coordinates, this.isFound = false});

  factory Difference.fromJson(List<dynamic> jsonList) {
    List<Coordinate> coordinates =
        jsonList.map((jsonCoord) => Coordinate.fromJson(jsonCoord)).toList();
    return Difference(coordinates: coordinates);
  }

  Difference copyWith({
    List<Coordinate>? coordinates,
    bool? isFound,
  }) {
    return Difference(
      coordinates: coordinates ?? this.coordinates,
      isFound: isFound ?? this.isFound,
    );
  }
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
        x: json['x'] ?? 0,
        y: json['y'] ?? 0,
      );

  Coordinate copyWith({
    int? x,
    int? y,
  }) {
    return Coordinate(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}
