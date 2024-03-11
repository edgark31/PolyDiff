import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/services/image_converter_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

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
  bool isLoading = false;
  String errorMessage = "ho";

  @override
  Widget build(BuildContext context) {
    final gameCardService = context.watch<GameCardService>();
    final gameCardsFromServer = gameCardService.gameCards;

    return Scaffold(
      // drawer: CustomMenuDrawer(),
      // appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Création d\'une salle de jeu - Mode Classique'),
            Text('Choisissez une fiche'),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: gameCardsFromServer.length,
                    itemBuilder: (context, index) {
                      return buildGameCard(context, gameCardsFromServer[index]);
                    },
                  ),
            CustomButton(
              text: 'Obtenir les jeux du serveur',
              press: () async {
                setState(() => isLoading = true);
                String? serverErrorMessage =
                    await gameCardService.getGameCards();
                setState(() => isLoading = false);

                if (serverErrorMessage == null) {
                  print('Game cards fetched from server');
                } else {
                  setState(() {
                    errorMessage = serverErrorMessage;
                  });
                }
              },
              backgroundColor: kMidGreen,
              widthFactor: 0.5,
            ),
            Text(
              errorMessage,
              style: TextStyle(
                  color: const Color.fromARGB(255, 240, 16, 0),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGameCard(BuildContext context, GameCard card) {
    final imageConverterService = ImageConverterService();
    final lobbyService = context.watch<LobbyService>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              leading: Image.memory(
                imageConverterService.uint8listFromBase64String(card.thumbnail),
                width: 100,
                height: 100,
              ),
              title: Text(card.name),
              subtitle: Text('Différences: ${card.nDifferences}'),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                CustomButton(
                  press: () {
                    print('Selected game card with gameId: ${card.gameId}');
                    lobbyService.setGameId(card.gameId);
                    Navigator.pushNamed(context, CREATE_ROOM_OPTIONS_ROUTE);
                  },
                  text: 'Choisir cette fiche',
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
