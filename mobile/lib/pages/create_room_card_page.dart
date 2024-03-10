import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/game_card_service.dart';
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
                    shrinkWrap:
                        true, // Use this if inside a SingleChildScrollView
                    physics:
                        NeverScrollableScrollPhysics(), // to disable ListView's scrolling
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
                  // socketService.setup(SocketType.Auth, infoService.username);
                  // chatService.setListeners(); // TODO : move this (maybe)
                  // Navigator.pushNamed(context, DASHBOARD_ROUTE);
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            ListTile(
              leading: Image.asset(
                card.thumbnail,
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


// class _CreateRoomCardPageState extends State<CreateRoomCardPage> {
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _gameCardProvider = GameCardProvider(baseUrl: API_URL);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final gameCardService = context.watch<GameCardService>();
//     final gameCardsFromServer = gameCardService.gameCards;
//     return Scaffold(
//       drawer: CustomMenuDrawer(),
//       appBar: CustomAppBar(),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Text('Création d\'une salle de jeu - Mode Classique'),
//             Text('Choississez une fiche'),
//             buildGameCard(context, defaultGameCard),
//             CustomButton(
//               text: 'Obtenir les jeux du serveur',
//               press: () async {
//                 await gameCardService.getGameCards();
//               },
//               backgroundColor: kMidGreen,
//               widthFactor: 0.5,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildGameCard(BuildContext context, GameCard card) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Card(
//         elevation: 5,
//         child: Column(
//           children: [
//             ListTile(
//               leading: Image.asset(
//                 card.thumbnail,
//                 width: 100,
//                 height: 100,
//               ),
//               title: Text(card.name),
//               subtitle: Text('Différences: ${card.nDifferences}'),
//             ),
//             ButtonBar(
//               alignment: MainAxisAlignment.start,
//               children: [
//                 CustomButton(
//                   press: () {
//                     Navigator.pushNamed(context, CREATE_ROOM_OPTIONS_ROUTE);
//                   },
//                   text: 'Choisir cette fiche',
//                   backgroundColor: kMidOrange,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
