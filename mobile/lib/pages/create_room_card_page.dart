import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_menu_drawer.dart';

class CreateRoomCardPage extends StatefulWidget {
  const CreateRoomCardPage({Key? key});

  static const routeName = CREATE_ROOM_CARD_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const CreateRoomCardPage(),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  State<CreateRoomCardPage> createState() => _CreateRoomCardPageState();
}

class _CreateRoomCardPageState extends State<CreateRoomCardPage> {
  // @override
  // void initState() {
  //   super.initState();
  //   _gameCardProvider = GameCardProvider(baseUrl: API_URL);
  // }

  GameCard defaultGameCard = GameCard(
    name: 'MASTER RACCOON',
    gameId: '1',
    gameMode: GameMode.classic,
    nDifferences: 7,
    numbersOfPlayers: 2,
    thumbnail: 'assets/images/admin raccoon.jpeg',
    playerUsernames: ["PlayerOne", "PlayerTwo"],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Création d\'une salle de jeu - Mode Classique'),
            Text('Choississez une fiche'),
            buildGameCard(context, defaultGameCard),
            // You can add more GameCard widgets here or iterate over a list of game cards
          ],
        ),
      ),
    );
  }

  Widget buildGameCard(BuildContext context, GameCard card) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    AssetImage(card.thumbnail), // Display game image
                radius: 30,
              ),
              title: Text(card.name),
              subtitle: Text(
                  'Différences: ${card.nDifferences}, Nombre de joueurs: ${card.numbersOfPlayers}/4'),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Joueurs: ${card.playerUsernames.join(', ')}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                CustomButton(
                  press: () {
                    // TODO: Handle lobby selection
                    print("Selected lobby with Game ID: ${card.gameId}");
                  },
                  text: 'Join Lobby',
                  backgroundColor: kMidOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
