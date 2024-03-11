import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    String creationRoute = lobbyService.isGameModesClassic()
        ? CREATE_ROOM_CARD_ROUTE
        : CREATE_ROOM_OPTIONS_ROUTE;
    final lobbiesFromServerOfSpecificMode = lobbyService.lobbies
        .where((lobby) => lobby.mode == lobbyService.gameModes)
        .toList();
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
                        'Créer une salle pour le mode ${lobbyService.gameModesName}',
                      )),
                  lobbiesFromServerOfSpecificMode.isEmpty
                      ? Text(
                          'Aucune salle d\'attente disponible pour le Mode ${lobbyService.gameModes}')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: lobbiesFromServerOfSpecificMode.length,
                          itemBuilder: (context, index) {
                            return buildLobbyCard(context,
                                lobbiesFromServerOfSpecificMode[index]);
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget buildLobbyCard(BuildContext context, Lobby lobby) {
    bool isLobbyClassic = lobby.mode == GameModes.Classic;
    String lobbyName = isLobbyClassic ? 'Classique' : 'Temps limité';
    // TODO : add classic game card thumbnail from url with lobby.gameId
    // Change 'assets/images/placeholderThumbnail.bmp' to dynamic path
    String imagePath = isLobbyClassic
        ? 'assets/images/placeholderThumbnail.bmp'
        : 'assets/images/limitedTime.png';
    String differences =
        isLobbyClassic ? 'Différences: ${lobby.nDifferences}, ' : '';
    String nPlayers = 'Nombre de joueurs: ${lobby.players.length}/4';
    String playerNames = lobby.players.map((e) => e.name).join(', ');
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
                    child: Text('Joueurs: $playerNames',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                lobby.isAvailable
                    ? (lobby.players.length == 4
                        ? const Text('Salle d\'attente pleine')
                        : CustomButton(
                            press: () {
                              print("Selected lobby with id: ${lobby.lobbyId}");
                              lobbyService.setIsCreator(false);
                              lobbyService.joinLobby(lobby.lobbyId);
                              Navigator.pushNamed(context, LOBBY_ROUTE);
                            },
                            text: 'Rejoindre cette salle d\'attente',
                            widthFactor: 1.5,
                            backgroundColor: kMidOrange,
                          ))
                    : CustomButton(
                        text: 'Observer cette partie',
                        press: () {
                          // TODO : Add join as Observer logic
                          print(
                              'Player is joining as observer in lobby ${lobby.lobbyId}');
                        },
                        backgroundColor: kMidGreen,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
