import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
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
                      APP_NAME_TXT,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: SIGN_IN_BTN_TXT,
                        press: () {
                          Navigator.pushNamed(context, SIGN_IN_ROUTE);
                        },
                        backgroundColor: kMidGreen,
                      ),
                      SizedBox(width: 125),
                      CustomButton(
                        text: SIGN_UP_BTN_TXT,
                        press: () {
                          Navigator.pushNamed(context, SIGN_UP_ROUTE);
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
