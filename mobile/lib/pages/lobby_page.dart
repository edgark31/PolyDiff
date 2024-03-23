import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';
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
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    final chatService = context.watch<ChatService>();
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();
    final gameManagerService = context.watch<GameManagerService>();
    List<String> playerNames = lobbyService.lobby.players.map((e) {
      return e.name ?? '';
    }).toList();
    String gameModeName = lobbyService.gameModes.name;

    if (!lobbyService.isCurrentLobbyInLobbies()) {
      Future.delayed(Duration.zero, () {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          print('Current Lobby not in Lobbies navigating to DashBoardPage');
          Navigator.pushNamed(context, DASHBOARD_ROUTE);
        }
      });
    } else if (lobbyService.isCurrentLobbyStarted()) {
      Future.delayed(Duration.zero, () {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          print('Current Lobby is started navigating to GamePage');
          socketService.setup(SocketType.Game, infoService.id);
          chatService.setupGame();
          gameManagerService.setupGame();
          // gameManagerService.setListeners(); // in setup
          // gameManagerService.setEndGameMessage(null); // in setup
          // if (lobbyService.isCreator) {
          lobbyService.setIsCreator(false); // TODO: clean this
          // gameManagerService.startGame(lobbyService.lobby.lobbyId); // in setup
          // }
          // Future.delayed(Duration(milliseconds: 2000), () {
          // Waiting for server to emit the created game from creator
          Navigator.pushNamed(context, CLASSIC_ROUTE);
          // });
        }
      });
    }

    return BackgroundContainer(
      backgroundImagePath: SELECTION_BACKGROUND_PATH,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text('Salle d\'attente de la partie en $gameModeName'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChatBox(),
                  playersInfos(context, playerNames: playerNames),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  lobbyButton(context),
                  CustomButton(
                    text: 'Quitter la salle d\'attente',
                    press: () {
                      print('Quitting lobby');
                      lobbyService.leaveLobby();
                      Navigator.pushNamed(context, DASHBOARD_ROUTE);
                    },
                    backgroundColor: kMidOrange,
                    widthFactor: 0.3,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget lobbyButton(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    int nPlayers = lobbyService.lobby.players.length;
    if (!lobbyService.isCreator) {
      return Text('En attente du début de la partie...');
    }
    if (nPlayers >= 2 && nPlayers <= 4) {
      return CustomButton(
        text: 'Commencer la partie',
        press: () {
          print('Starting the lobby');
          lobbyService.startLobby();
          // TODO: Add loading message for creator
          // Navigator.pushNamed(context, CLASSIC_ROUTE);
        },
        backgroundColor: kMidGreen,
      );
    } else {
      return Text(
          'Vous devez être entre 2 et 4 joueurs pour commencer la partie');
    }
  }

  Widget playersInfos(BuildContext context,
      {List<String> playerNames = const []}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nombre de joueurs: ${playerNames.length}/4'),
          Text('Joueurs en ligne',
              style: Theme.of(context).textTheme.titleLarge),
          ...playerNames.map((name) => Text(name)),
        ],
      ),
    );
  }
}
