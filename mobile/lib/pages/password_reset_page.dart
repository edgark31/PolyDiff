import 'package:flutter/material.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  State<PasswordResetPage> createState() => _PasswordResetPage();
}

class _PasswordResetPage extends State<PasswordResetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Page d'administration"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/raccoon cafe.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            '',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
