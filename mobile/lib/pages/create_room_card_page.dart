import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/services.dart';
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
  bool _isFetchingGameCards = false;
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFetchingGameCards) {
      _isFetchingGameCards = true;
      _fetchGameCards();
    }
  }

  void startPracticeGame() {
    final LobbyService lobbyService = Get.find();
    final SocketService socketService = Get.find();
    final GameManagerService gameManagerService = Get.find();
    final LobbySelectionService lobbySelectionService = Get.find();
    final infoService = context.read<InfoService>();
    lobbySelectionService.setIsCheatEnabled(false); // Practice has no cheat
    lobbySelectionService.setGameDuration(0); // Practice has no time limit
    lobbyService.createLobby();
    print('createLobby() called');
    Future.delayed(Duration(milliseconds: 500), () {
      // Waiting for server to emit the created lobby from creator
      lobbyService.startLobby();
      setState(() => isLoading = true);
      print('startLobby() called');
      Future.delayed(Duration(milliseconds: 500), () {
        // Waiting for server to  start Lobby
        if (lobbyService.isCurrentLobbyStarted()) {
          Future.delayed(Duration.zero, () {
            // Safety check
            if (ModalRoute.of(context)?.isCurrent ?? false) {
              // Safety check
              print('Current Lobby is started navigating to GamePage');
              socketService.setup(SocketType.Game, infoService.id);
              gameManagerService.setupGame();
              lobbyService.setIsCreator(false); // TODO: clean this
              setState(() => isLoading = false);
              Navigator.pushNamed(context, PRACTICE_ROUTE);
            }
          });
        }
      });
    });
  }

  Future<void> _fetchGameCards() async {
    setState(() => isLoading = true);
    final gameCardService =
        Provider.of<GameCardService>(context, listen: false);
    String? serverErrorMessage = await gameCardService.getGameCards();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (serverErrorMessage != null) {
          errorMessage = serverErrorMessage;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameCardService = context.watch<GameCardService>();
    final gameCardsFromServer = gameCardService.gameCards;
    // TODO : Reload game cards if new games are added to the server

    return Scaffold(
      // TODO : Think problems if drawer and appbar are used
      // drawer: CustomMenuDrawer(),
      // appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Création d\'une salle de jeu'),
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
    final lobbySelectionService = context.watch<LobbySelectionService>();
    final lobbyService = context.watch<LobbyService>();
    String imagePath = '$BASE_URL/${card.id}/original.bmp';
    String differenceText = 'Différences: ${card.nDifference}';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              leading: Image.network(imagePath),
              title: Text(card.name),
              subtitle: Text(differenceText),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                CustomButton(
                  press: () {
                    lobbySelectionService.setGameId(card.id);
                    lobbySelectionService.setNDifferences(card.nDifference);
                    if (lobbyService.gameModes == GameModes.Practice) {
                      startPracticeGame();
                    } else {
                      Navigator.pushNamed(context, CREATE_ROOM_OPTIONS_ROUTE);
                    }
                  },
                  text: 'Choisir cette fiche',
                  backgroundColor: kMidOrange,
                  widthFactor: 0.25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
