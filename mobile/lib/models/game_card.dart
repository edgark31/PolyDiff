// Note: GameCard in common also has
// soloTopTime: PlayerTime[];
// oneVsOneTopTime: PlayerTime[];
// but attributes are not need on mobile
class GameCard {
  String id; // Attribute in _id in common
  String name;
  bool difficultyLevel; // Useless attribute
  String thumbnail; // Useless attribute
  // Since thumbnail are showed with id and url
  int? nDifference;

  GameCard({
    required this.id,
    required this.name,
    required this.difficultyLevel,
    required this.nDifference,
    required this.thumbnail,
  });

  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      id: json['_id'] as String,
      name: json['name'] as String,
      difficultyLevel: json['difficultyLevel'] as bool,
      nDifference: json['nDifference'],
      thumbnail: json['thumbnail'] as String,
    );
  }
}
