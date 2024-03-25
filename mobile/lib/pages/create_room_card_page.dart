import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/game_card_service.dart';
import 'package:mobile/services/lobby_selection_service.dart';
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
                    Navigator.pushNamed(context, CREATE_ROOM_OPTIONS_ROUTE);
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
