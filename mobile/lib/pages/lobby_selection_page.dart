import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/game_card_provider.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class LobbySelectionPage extends StatefulWidget {
  const LobbySelectionPage({Key? key});

  static const routeName = LOBBY_SELECTION_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const LobbySelectionPage(),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  State<LobbySelectionPage> createState() => _LobbySelectionPageState();
}

class _LobbySelectionPageState extends State<LobbySelectionPage> {
  late GameCardProvider _gameCardProvider;

  bool _isLoading = false;

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
  void initState() {
    super.initState();
    _gameCardProvider = GameCardProvider(baseUrl: API_URL);
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    String creationRoute = lobbyService.isGameTypeClassic()
        ? CREATE_ROOM_CARD_ROUTE
        : CREATE_ROOM_OPTIONS_ROUTE;
    return Scaffold(
      // drawer: CustomMenuDrawer(),
      // appBar: CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, creationRoute),
                      child: Text(
                        'Créer une salle pour le mode ${lobbyService.gameTypeName}',
                      )),
                  buildLobbyCard(context, defaultGameCard,
                      lobbyService.isGameTypeClassic()),
                  // You can add more GameCard widgets here or iterate over a list of game cards
                ],
              ),
            ),
    );
  }

  Widget buildLobbyCard(
      BuildContext context, GameCard card, bool isClassicGame) {
    String lobbyName = isClassicGame ? card.name : 'Temps limité';
    String imagePath =
        isClassicGame ? card.thumbnail : 'assets/images/limitedTime.png';
    String differences =
        isClassicGame ? 'Différences: ${card.nDifferences}, ' : '';
    String nPlayers = 'Nombre de joueurs: ${card.numbersOfPlayers}/4';
    final lobbyService = context.watch<LobbyService>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(imagePath),
                radius: 30,
                backgroundColor: kLight,
              ),
              title: Text(lobbyName),
              subtitle: Text('$differences$nPlayers'),
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
                    lobbyService.setIsCreator(false);
                    Navigator.pushNamed(context, LOBBY_ROUTE);
                  },
                  text: 'Rejoindre cette salle d\'attente',
                  widthFactor: 1.5,
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
