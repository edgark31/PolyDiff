import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/customs/stroked_text_widget.dart';
import 'package:mobile/widgets/sign_in_form.dart';

class SignInPage extends StatelessWidget {
  static const routeName = SIGN_IN_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => SignInPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double startingPoint = screenHeight * 0.2;
    return Stack(
      children: [
        BackgroundContainer(
          backgroundImagePath: SELECTION_BACKGROUND_PATH,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: startingPoint),
                    child: StrokedTextWidget(
                      text: APP_NAME_TXT,
                      textStyle: TextStyle(
                        fontFamily: 'troika',
                        fontSize: 140,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8A430),
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  SignInForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
