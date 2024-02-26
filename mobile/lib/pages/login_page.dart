import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/background_container.dart.dart'; // Make sure the path is correct
import 'package:mobile/widgets/connection_form.dart';

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
            child: ConnectionForm(),
          )
        ],
      ),
    );
  }
}
