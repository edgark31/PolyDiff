import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class ReplayPopUp extends StatelessWidget {
  final VoidCallback onReplay;
  final VoidCallback onGoHome;
  final String endMessage;

  const ReplayPopUp({
    super.key,
    required this.endMessage,
    required this.onGoHome,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                  endMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                CustomButton(
                  text: AppLocalizations.of(context)!.endGame_homeButton,
                  press: onGoHome,
                ),
                SizedBox(height: 10),
                CustomButton(
                  text: AppLocalizations.of(context)!.endGame_videoReplayButton,
                  press: onReplay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
