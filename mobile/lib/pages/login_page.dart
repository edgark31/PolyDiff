import 'package:flutter/material.dart';
import 'package:mobile/widgets/background_image.dart.dart'; // Make sure the path is correct
import 'package:mobile/widgets/connection_form.dart';

class LoginPage extends StatelessWidget {
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
