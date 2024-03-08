import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/game_card_provider.dart';

class LobbySelectionPage extends StatefulWidget {
  const LobbySelectionPage({Key? key});

  static const routeName = CLASSIC_LOBBY_ROUTE;

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
    _gameCardProvider = GameCardProvider(baseUrl: BASE_URL);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Lobby"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
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
                ElevatedButton(
                  onPressed: () {
                    // Handle lobby selection
                    print("Selected lobby with Game ID: ${card.gameId}");
                  },
                  child: const Text('Join Lobby'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
