import 'package:flutter/material.dart';

class GameInfos extends StatefulWidget {
  @override
  State<GameInfos> createState() => _GameInfosState();
}

class _GameInfosState extends State<GameInfos> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Connect these attributes to real values from the server or lobby
    int timer = 240;
    int nbDifferencesPresent = 4;
    String gameMode = "Classic";
    int nbPlayers = 5;

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
                Text(
                  'Temps : $formattedTime',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
            Text(
              'Nombre de différences présentes : $nbDifferencesPresent',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 30,
                ),
                Text(
                  'Jerem',
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
                  'Différences trouvées : 0',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: 130,
                ),
                Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 30,
                ),
                Text(
                  'MP',
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
                  'Différences trouvées : 0',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                    'Edgar',
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
                    'Différences trouvées : 0',
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
                    'Zaki',
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
                    'Différences trouvées : 0',
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
