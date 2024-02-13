import 'package:flutter/material.dart';
import 'package:mobile/widgets/signup_form.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Expanded(
              child: Center(
                child: CreationFormScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
