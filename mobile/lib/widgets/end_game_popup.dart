import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class EndGamePopup extends StatelessWidget {
  const EndGamePopup({
    required this.endMessage,
    required this.canPlayerReplay,
  });

  final String endMessage;
  final bool canPlayerReplay;

  @override
  Widget build(BuildContext context) {
    String endMessageDisplayed = '';

    if (endMessage == 'Temps écoulé, match nul !') {
      endMessageDisplayed =
          AppLocalizations.of(context)!.endGameMessage_timesUp;
    } else if (endMessage.endsWith('a gagné !')) {
      endMessageDisplayed = endMessage.replaceFirst(
          'a gagné !', AppLocalizations.of(context)!.endGameMessage_playerWon);
    } else if (endMessage.endsWith('a abandonné !')) {
      endMessageDisplayed = endMessage.replaceFirst(
          'a abandonné !', AppLocalizations.of(context)!.endGameMessage_playerAbandoned);
    } else if (endMessage == "Match nul !") {
      endMessageDisplayed = AppLocalizations.of(context)!.endGameMessage_draw;
    } else if (endMessage == "Fin de la pratique !") {
      endMessageDisplayed =
          AppLocalizations.of(context)!.endGameMessage_endPractice;
    } else {
      endMessageDisplayed = endMessage;
    }

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400.0,
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
                  endMessageDisplayed,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                CustomButton(
                  text: AppLocalizations.of(context)!.endGame_homeButton,
                  press: () {
                    Navigator.pushNamed(context, DASHBOARD_ROUTE);
                  },
                ),
                if (canPlayerReplay) ...[
                  SizedBox(height: 10),
                  CustomButton(
                    text:
                        AppLocalizations.of(context)!.endGame_videoReplayButton,
                    press: () {
                      Navigator.pushNamed(context, REPLAY_ROUTE);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
