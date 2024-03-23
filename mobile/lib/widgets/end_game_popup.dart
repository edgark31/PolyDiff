import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class EndGamePopup extends StatelessWidget {
  const EndGamePopup({
    required this.endMessage,
    required this.gameMode,
  });

  final String endMessage;
  final GameModes gameMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            endMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        if (gameMode == GameModes.Classic) ...[
          CustomButton(
            text: 'Accueil',
            press: () {
              Navigator.pushNamed(context, DASHBOARD_ROUTE);
            },
            backgroundColor: kMidOrange,
          ),
          SizedBox(height: 10), // Space between buttons
           CustomButton(
            text: 'Reprise Vidéo',
            press: () {
              
              print('Navigate to replay video page');
            },
            backgroundColor: kMidOrange,
          ),
        ],
      ],
    );
  }
}
