import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class EndGamePopup extends StatelessWidget {
  const EndGamePopup({
    required this.endMessage,
    required this.gameMode,
    required this.isObserver,
  });

  final String endMessage;
  final GameModes gameMode;
  final bool isObserver;

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
                text: 'Accueil',
                press: () {
                  Navigator.pushNamed(context, DASHBOARD_ROUTE);
                },
              ),
              if (gameMode == GameModes.Classic && !isObserver) ...[
                SizedBox(height: 10),
                CustomButton(
                  text: 'Reprise Vidéo',
                  press: () {
                    print('Navigate to replay video page');
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
