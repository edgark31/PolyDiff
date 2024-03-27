import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/players.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:provider/provider.dart';

class GameInfos extends StatefulWidget {
  @override
  State<GameInfos> createState() => _GameInfosState();
}

class _GameInfosState extends State<GameInfos> {
  final GameManagerService gameManagerService = Get.find();
  final LobbyService lobbyService = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameManagerService = context.watch<GameManagerService>();
    final lobbyService = context.watch<LobbyService>();
    int timer = gameManagerService.time;
    int? nbDifferencesPresent = gameManagerService.game.nDifferences;
    List<Player> players = lobbyService.lobby.players;
    String gameMode = lobbyService.lobby.mode.name;

    String formattedTime =
        "${(timer ~/ 60).toString().padLeft(2, '0')}:${(timer % 60).toString().padLeft(2, '0')}";
    return SizedBox(
        width: 100,
        height: 50,
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 380),
                Text(
                  'Mode de jeu : $gameMode',
                  style: _textStyle(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 100),
                if (lobbyService.lobby.mode != GameModes.Practice) ...[
                  Text(
                    'Temps : $formattedTime',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            if (lobbyService.lobby.mode == GameModes.Classic) ...[
              Text(
                'Nombre de différences présentes : $nbDifferencesPresent',
                style:_textStyle(),
                textAlign: TextAlign.center,
              ),
            ],
            Row(
              children: [
                if (players.isNotEmpty) ...[
                  _playerInfo(players[0]),
                ],
                SizedBox(
                  width: 130,
                ),
                if (players.length > 1) ...[
                  _playerInfo(players[1]),
                ],
              ],
            ),
            Row(
              children: [
                if (players.length >= 3) ...[
                  _playerInfo(players[2]),
                ],
                if (players.length >= 4) ...[
                  SizedBox(
                    width: 130,
                  ),
                  _playerInfo(players[3]),
                ],
              ],
            )
          ],
        ));
  }

  Widget _playerInfo(Player player) {
    return Row(
      children: [
        Icon(
          Icons.person,
          color: Colors.black,
          size: 30,
        ),
        Text(
          player.name!,
          style: _textStyle(),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: 30,
        ),
        Text(
          'Différences trouvées : ${player.count}',
          style: _textStyle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }
}
