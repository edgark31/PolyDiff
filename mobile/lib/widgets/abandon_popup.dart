import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/game_manager_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class AbandonPopup extends StatelessWidget {
  final LobbyService lobbyService = Get.find();
  final GameManagerService gameManagerService = Get.find();

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    final gameManagerService = context.watch<GameManagerService>();
    return Center(
      child: SizedBox(
        width: 600.0,
        height: 500.0,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/woodenPopUp.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.abandonGame_questionTitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              CustomButton(
                text: AppLocalizations.of(context)!.confirmation_yes,
                press: () {
                  gameManagerService.abandonGame(lobbyService.lobby.lobbyId);
                  Navigator.pushNamed(context, DASHBOARD_ROUTE);
                },
              ),
              SizedBox(height: 10),
              CustomButton(
                text: AppLocalizations.of(context)!.confirmation_no,
                press: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
