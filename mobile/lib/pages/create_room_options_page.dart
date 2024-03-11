import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class CreateRoomOptionsPage extends StatefulWidget {
  const CreateRoomOptionsPage({super.key});

  static const routeName = CREATE_ROOM_OPTIONS_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const CreateRoomOptionsPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<CreateRoomOptionsPage> createState() => _CreateRoomOptionsPageState();
}

class _CreateRoomOptionsPageState extends State<CreateRoomOptionsPage> {
  bool cheatMode = false;
  double gameDuration = 30;

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();

    return Scaffold(
      // appBar: CustomAppBar(),
      // drawer: CustomMenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Sélectionner les options de la salle de jeu en Mode ${lobbyService.gameModesName}'),
            cheatSetting(context),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
            ),
            lobbyService.isGameModesClassic()
                ? const SizedBox()
                : timeSelection(context),
            CustomButton(
              press: () {
                socketService.setup(SocketType.Lobby, infoService.id);
                lobbyService.setIsCheatEnabled(cheatMode);
                lobbyService.setGameDuration(gameDuration.round());
                lobbyService.setListeners();
                lobbyService.createLobby();
                Navigator.pushNamed(context, LOBBY_ROUTE);
              },
              text: 'Créer la salle de jeu',
              backgroundColor: kMidOrange,
            ),
            CustomButton(
              press: () {
                // TODO: Make sure the page does not count stats + no clock
                print("Navigate to game page but stats do not count");
                Navigator.pushNamed(context, CLASSIC_ROUTE);
              },
              text: 'Mode pratique',
              backgroundColor: kMidOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget cheatSetting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Mode de triche'),
        Checkbox(
          value: cheatMode,
          onChanged: (bool? newValue) {
            setState(() {
              cheatMode = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget timeSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Temps initial de la partie (en secondes)'),
        Slider(
          value: gameDuration,
          min: 30,
          max: 60,
          divisions: 60,
          label: gameDuration.round().toString(),
          onChanged: (double newValue) {
            setState(() {
              gameDuration = newValue;
            });
          },
        ),
      ],
    );
  }
}
