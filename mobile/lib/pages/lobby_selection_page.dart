import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/game_card_provider.dart';

class LobbySelectionPage extends StatefulWidget {
  const LobbySelectionPage({Key? key});

  static const routeName = CLASSIC_LOBBY_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => LobbySelectionPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<LobbySelectionPage> createState() => _LobbySelectionPageState();
}

class _LobbySelectionPageState extends State<LobbySelectionPage> {
  late GameCardProvider _gameCardProvider;
  List<GameCard> _gameCards = [];
  bool _isLoading = true;

  // TODO: replace when sockets logic is done
  GameCard defaultGameCard = GameCard(
    name: 'MASTER RACCOON',
    gameId: '1',
    gameMode: GameMode.classic,
    nDifferences: 7,
    numbersOfPlayers: 2,
    thumbnail: 'assets/images/admin raccoon.jpeg',
  );

  @override
  void initState() {
    super.initState();
    _gameCardProvider = GameCardProvider(baseUrl: BASE_URL);
    // _fetchGameCards();
  }

  // void _fetchGameCards() async {
  //   try {
  //     List<GameCard> gameCards = await _gameCardProvider.getAll();
  //     setState(() {
  //       _gameCards = gameCards;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     print("Failed to load game cards: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a Lobby"),
      ),
      body: _isLoading
          // Loading progress
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _gameCards.length,
              itemBuilder: (context, index) {
                final card = _gameCards[index];
                return Card(
                  child: ListTile(
                    leading: Image.asset(defaultGameCard.thumbnail),
                    title: Text(
                        'Game ${defaultGameCard.gameId} - ${defaultGameCard.gameMode.toString().split('.').last}'),
                    subtitle: Text(
                        '${defaultGameCard.nDifferences} differences - ${defaultGameCard.numbersOfPlayers}/4 players'),
                    onTap: () {
                      // TODO: Handle lobby selection
                      print(
                          "Selected lobby with Game ID: ${defaultGameCard.gameId}");
                    },
                  ),
                );
              },
            ),
    );
  }
}
