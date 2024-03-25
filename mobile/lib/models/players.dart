import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/game.dart';

class Player {
  String? accountId;
  String? name;
  Differences? differenceData;
  int? count;

  Player({
    this.accountId,
    required this.name,
    required this.differenceData,
    this.count,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        accountId: json['accountId'],
        name: json['name'],
        differenceData: json['differenceData'] != null
            ? Differences.fromJson(json['differenceData'])
            : null,
        count: json['count'],
      );

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'name': name,
        'differenceData': differenceData?.toJson(),
        'count': count,
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
