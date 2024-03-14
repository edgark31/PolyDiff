import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/customs/background_container.dart';
import 'package:mobile/widgets/sign_up.dart';

class SignUpPage extends StatelessWidget {
  static const routeName = SIGN_UP_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => SignUpPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          BackgroundContainer(
            backgroundImagePath: SELECTION_BACKGROUND_PATH,
            child: SignUp(),
          )
        ],
      ),
    );
  }
}
