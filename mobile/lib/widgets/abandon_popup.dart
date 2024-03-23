import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class AbandonPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                "Êtes-vous certain de vouloir abandonner la partie ?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              CustomButton(
                text: 'Oui',
                press: () {
                  Navigator.pushNamed(context, DASHBOARD_ROUTE);
                },
                backgroundColor: kMidGreen,
              ),
              SizedBox(height: 10),
              CustomButton(
                text: 'Non',
                press: () {
                  Navigator.pop(context);
                },
                backgroundColor: kMidOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
