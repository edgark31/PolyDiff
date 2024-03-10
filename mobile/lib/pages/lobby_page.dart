import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/chat_box.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({Key? key});

  static const routeName = LOBBY_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => const LobbyPage(),
      settings: const RouteSettings(name: routeName),
    );
  }

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    bool isCreator =
        true; // TODO : Implement logic to check if the user is the creator of the lobby
    List<String> fakePlayerNames = [
      'Player1name',
      'Player2name',
      'Player3name'
    ]; // TODO: Replace with actual data source
    return BackgroundContainer(
      backgroundImagePath:
          SELECTION_BACKGROUND_PATH, // TODO : fix white background
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                  'Salle d\'attente de la partie en ${lobbyService.gameTypeName}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TODO: Add looby + game specific chat logic
                  ChatBox(),
                  playersInfos(context, playerNames: fakePlayerNames),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isCreator
                      ? CustomButton(
                          text: 'Commencer la partie',
                          press: () {
                            print('Navigating to GamePage');
                            // TODO: Implement logic when the game starts
                          },
                          backgroundColor: kMidGreen,
                        )
                      : Text('En attente du début de la partie...'),
                  CustomButton(
                    text: 'Quitter la salle d\'attente',
                    press: () {
                      print('Navigating to Dashboard');
                      Navigator.pushNamed(context, DASHBOARD_ROUTE);
                    },
                    backgroundColor: kMidOrange,
                  )
                ],
              ),
              // You can add more GameCard widgets here or iterate over a list of game cards
            ],
          ),
        ),
      ),
    );
  }

  Widget playersInfos(BuildContext context,
      {List<String> playerNames = const []}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Joueurs en ligne',
              style: Theme.of(context).textTheme.titleLarge),
          ...playerNames.map((name) => Text(name)).toList(),
        ],
      ),
    );
  }
}
