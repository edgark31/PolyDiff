class GameCard {
  String name;
  String thumbnail;
  List<PlayerTime> oneVsOneTopTime;
  List<PlayerTime> soloTopTime;
  bool difficultyLevel;
  String id;

  GameCard({
    required this.name,
    required this.thumbnail,
    required this.oneVsOneTopTime,
    required this.soloTopTime,
    required this.difficultyLevel,
    required this.id,
  });

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      name: json['name'],
      thumbnail: json['thumbnail'],
      oneVsOneTopTime: List<PlayerTime>.from(
          json['oneVsOneTopTime'].map((model) => PlayerTime.fromJson(model))),
      soloTopTime: List<PlayerTime>.from(
          json['soloTopTime'].map((model) => PlayerTime.fromJson(model))),
      difficultyLevel: json['difficultyLevel'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'thumbnail': thumbnail,
      'oneVsOneTopTime': oneVsOneTopTime.map((e) => e.toJson()).toList(),
      'soloTopTime': soloTopTime.map((e) => e.toJson()).toList(),
      'difficultyLevel': difficultyLevel,
      '_id': id,
    };
  }
}

class PlayerTime {
  String name;
  int time;

  PlayerTime({required this.name, required this.time});

  factory PlayerTime.fromJson(Map<String, dynamic> json) {
    return PlayerTime(
      name: json['name'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
    };
  }
}
