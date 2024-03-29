import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/services/lobby_selection_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_menu_drawer.dart';
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
  bool cheatMode = true;
  double gameDuration = 30;
  double gameBonus = 10;

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    final lobbySelectionService = context.watch<LobbySelectionService>();
    final gameModeName = lobbyService.gameModes.name;

    return Scaffold(
      appBar: CustomAppBar(title: 'Configurations des options'),
      drawer: CustomMenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Sélectionner les options de la salle de jeu en Mode $gameModeName'),
            cheatSetting(context),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
            ),
            timeSelection(context),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
            ),
            if (lobbyService.gameModes == GameModes.Limited) ...[
              bonusTimeSelection(context),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
              ),
            ],
            CustomButton(
              press: () {
                lobbySelectionService.setIsCheatEnabled(cheatMode);
                lobbySelectionService.setGameDuration(gameDuration.round());
                lobbySelectionService.setGameBonus(gameBonus.round());
                lobbyService.createLobby();
                Future.delayed(Duration(milliseconds: 500), () {
                  // Waiting for server to emit the created lobby from creator
                  Navigator.pushNamed(context, LOBBY_ROUTE);
                });
              },
              text: 'Créer la salle de jeu',
              widthFactor: 0.25,
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
          max: 600, // TODO: Change back to 60 when testing is done
          divisions: 30,
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

  Widget bonusTimeSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Temps de bonus pour différence trouvée (en secondes)'),
        Slider(
          value: gameBonus,
          min: 10,
          max: 20,
          divisions: 10,
          label: gameBonus.round().toString(),
          onChanged: (double newValue) {
            setState(() {
              gameBonus = newValue;
            });
          },
        ),
      ],
    );
  }
}
