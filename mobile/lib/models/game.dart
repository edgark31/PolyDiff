class Game {
  String name;
  String originalImage;
  String modifiedImage;
  int nDifference;
  String differences;
  bool isHard;
  String? id;

  Game({
    required this.name,
    required this.originalImage,
    required this.modifiedImage,
    required this.nDifference,
    required this.differences,
    required this.isHard,
    this.id,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'],
      originalImage: json['originalImage'],
      modifiedImage: json['modifiedImage'],
      nDifference: json['nDifference'],
      differences: json['differences'],
      isHard: json['isHard'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'originalImage': originalImage,
      'modifiedImage': modifiedImage,
      'nDifference': nDifference,
      'differences': differences,
      'isHard': isHard,
      '_id': id,
    };
  }
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
