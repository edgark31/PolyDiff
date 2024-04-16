import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/constants/app_routes.dart';

class AdminPopup extends StatefulWidget {
  @override
  State<AdminPopup> createState() => _AdminPopupState();
}

class _AdminPopupState extends State<AdminPopup> {
  TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      if (passwordController.text.isEmpty) {
        setState(() {
          errorMessage = "";
        });
      }
    });
  }

  void handleSubmission(String password) {
    if (password == "admin") {
      passwordController.text = "";
      Navigator.pushNamed(context, ADMIN_ROUTE);
    } else {
      setState(() {
        errorMessage =
            AppLocalizations.of(context)!.adminPopup_incorrectPassword;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            width: 500,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/admin raccoon.jpeg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.55),
                  BlendMode.dstATop,
                ),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          Container(
            width: 500,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.adminPopup_loginTitle,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    AppLocalizations.of(context)!.adminPopup_passwordTitle,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(5, 5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 400,
                  height: 63,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(),
                    child: TextField(
                      onSubmitted: handleSubmission,
                      controller: passwordController,
                      obscureText: true,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(40),
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 21),
                  child: SizedBox(
                    width: 430,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        handleSubmission(passwordController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        backgroundColor: Color.fromARGB(255, 31, 150, 104),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          AppLocalizations.of(context)!.adminPopup_loginButton),
                    ),
                  ),
                ),
                Text(
                  errorMessage,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 240, 16, 0),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
