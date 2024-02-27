import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/connection_form.dart';
import 'package:mobile/widgets/customs/background_container.dart'; // Make sure the path is correct

class LoginPage extends StatelessWidget {
  static const routeName = LOGIN_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      builder: (_) => LoginPage(),
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
            child: ConnectionForm(),
          )
        ],
      ),
    );
  }
}
