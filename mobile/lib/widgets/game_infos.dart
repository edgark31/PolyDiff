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
    int nbPlayers = lobbyService.lobby.players.length;

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
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 170),
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
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 30,
                ),
                if (nbPlayers > 0) ...[
                  Text(
                    players[0].name!,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Différences trouvées : ${players[0].count}',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(
                  width: 130,
                ),
                if (nbPlayers > 1) ...[
                  Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 30,
                  ),
                  Text(
                    players[1].name as String,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Différences trouvées : ${players[1].count}',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            Row(
              children: [
                if (nbPlayers >= 3) ...[
                  Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 30,
                  ),
                  Text(
                    players[2].name as String,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Différences trouvées : ${players[2].count}',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (nbPlayers >= 4) ...[
                  SizedBox(
                    width: 130,
                  ),
                  Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 30,
                  ),
                  Text(
                    players[3].name as String,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Différences trouvées : ${players[3].count}',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            )
          ],
        ));
  }
}
