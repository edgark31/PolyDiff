import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/app_style.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  static const routeName = HOME_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => HomePage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double startingPoint = screenHeight * 0.5;
    return Stack(
      children: [
        BackgroundContainer(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: startingPoint),
                    child: Text(
                      "PolyDiff",
                      style: appstyle(60, kLightOrange, FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: 'C O N N E X I O N',
                        press: () {
                          Navigator.pushNamed(context, LOGIN_ROUTE);
                        },
                        backgroundColor: kMidGreen,
                      ),
                      SizedBox(width: 125),
                      CustomButton(
                        text: "S' I N S C R I R E",
                        press: () {
                          Navigator.pushNamed(context, SIGNUP_ROUTE);
                        },
                        backgroundColor: kLight,
                        textColor: kMidGreen,
                      ),
                      // TODO : Remove this button after testing canvas
                      SizedBox(width: 125),
                      CustomButton(
                        text: "C~A~N~V~A~S",
                        press: () {
                          Navigator.pushNamed(context, CLASSIC_ROUTE);
                        },
                        backgroundColor: kLight,
                        textColor: kMidGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
