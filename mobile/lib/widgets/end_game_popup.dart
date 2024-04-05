import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EndGamePopup extends StatelessWidget {
  const EndGamePopup({
    required this.endMessage,
    required this.canPlayerReplay,
  });

  final String endMessage;
  final bool canPlayerReplay;

  @override
  Widget build(BuildContext context) {
    return Center(
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
                endMessage,
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
                  text: AppLocalizations.of(context)!.endGame_videoReplayButton,
                  press: () {
                    Navigator.pushNamed(context, REPLAY_ROUTE);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
