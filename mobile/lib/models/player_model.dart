import 'dart:convert';

class Player {
  final String username;
  final String socketId;
  final double points;
  final String playerType;

  Player(
      {required this.username,
      required this.socketId,
      required this.points,
      required this.playerType});

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "socketId": socketId,
      "points": points,
      "playerType": playerType,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      username: map["username"] ?? '',
      socketId: map["socketId"] ?? '',
      points: map["points"].toDouble() ?? 0.0,
      playerType: map["playerType"] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source));

  Player copyWith({
    String? username,
    String? socketId,
    double? points,
    String? playerType,
  }) {
    return Player(
      username: username ?? this.username,
      socketId: socketId ?? this.socketId,
      points: points ?? this.points,
      playerType: playerType ?? this.playerType,
    );
  }
}
