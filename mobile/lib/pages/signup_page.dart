import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/widgets/signup_form.dart';

class SignUpPage extends StatelessWidget {
  static const routeName = SIGNUP_ROUTE;

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
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/MenuBackground.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Center(
              child: SignUpForm(),
            ),
          ),
        ],
      ),
    );
  }
}
