import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/game.dart';

class Player {
  String? playerId;
  String name;
  Differences differenceData;

  Player({this.playerId, required this.name, required this.differenceData});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        playerId: json['playerId'],
        name: json['name'],
        differenceData: Differences.fromJson(json['differenceData']),
      );

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'name': name,
        'differenceData': differenceData.toJson(),
      };
}

class PlayerData {
  String username;
  String gameId;
  GameModes gameMode;

  PlayerData(
      {required this.username, required this.gameId, required this.gameMode});

  factory PlayerData.fromJson(Map<String, dynamic> json) => PlayerData(
        username: json['username'],
        gameId: json['gameId'],
        gameMode: GameModes.values.firstWhere((e) =>
            e.toString() ==
            'GameModes.${json['GameModes']}'), // TODO : confirm this logic of iterate enums
      );

  Map<String, dynamic> toJson() => {
        'playerName': username,
        'gameId': gameId,
        'gameMode': gameMode.toString().split('.').last,
      };
}

class AcceptedPlayer {
  String gameId;
  String roomId;
  String playerName;

  AcceptedPlayer(
      {required this.gameId, required this.roomId, required this.playerName});

  factory AcceptedPlayer.fromJson(Map<String, dynamic> json) => AcceptedPlayer(
        gameId: json['gameId'],
        roomId: json['roomId'],
        playerName: json['playerName'],
      );

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'roomId': roomId,
        'playerName': playerName,
      };
}
