import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/chat_service.dart';
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
  final ChatService chatService = Get.find();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lobbyService = context.read<LobbyService>();
      lobbyService.addListener(_checkLobbyState);
    });
  }

  @override
  void dispose() {
    context.read<LobbyService>().removeListener(_checkLobbyState);
    super.dispose();
  }

  void _checkLobbyState() {
    final lobbyService = context.read<LobbyService>();
    if (lobbyService.isLobbyStarted) {
      chatService.clearLobbyMessages();
      print('Navigating to GamePage from _checkLobbyStart');
      Navigator.pushNamed(context, CLASSIC_ROUTE);
    } else if (!lobbyService.isCurrentLobbyInLobbies()) {
      print('Navigating to DashBoardPage from _checkLobbyStart');
      Navigator.pushNamed(context, DASHBOARD_ROUTE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    bool isCreator = lobbyService.isCreator;
    int nPlayers = lobbyService.lobby.players.length;
    bool canGameStart = nPlayers >= 2 && nPlayers <= 4;
    List<String> playerNames = lobbyService.lobby.players.map((e) {
      return e.name ?? '';
    }).toList();

    return BackgroundContainer(
      backgroundImagePath:
          SELECTION_BACKGROUND_PATH, // TODO : fix white background
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                  'Salle d\'attente de la partie en ${lobbyService.gameModesName}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TODO: Add lobby + game specific chat logic
                  ChatBox(),
                  playersInfos(context, playerNames: playerNames),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isCreator
                      ? (canGameStart
                          ? CustomButton(
                              text: 'Commencer la partie',
                              press: () {
                                print('Calling lobbyServce.startLobby');
                                lobbyService.startLobby();
                              },
                              backgroundColor: kMidGreen,
                            )
                          : Text(
                              'Vous devez être entre 2 et 4 joueurs pour commencer la partie'))
                      : Text('En attente du début de la partie...'),
                  CustomButton(
                    text: 'Quitter la salle d\'attente',
                    press: () {
                      print('Quitting lobby and navigating to Dashboard');
                      lobbyService.leaveLobby();
                      Navigator.pushNamed(context, DASHBOARD_ROUTE);
                    },
                    backgroundColor: kMidOrange,
                  ),
                ],
              ),
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
