// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/models/credentials.dart';
import 'package:mobile/pages/password_reset_page.dart';
import 'package:mobile/pages/signup_page.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/widgets/admin_popup.dart';

class ConnectionForm extends StatefulWidget {
  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
  final FormService formService = FormService('http://localhost:3000');
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    userNameController.addListener(() {
      if (userNameController.text.isEmpty) {
        setState(() {
          errorMessage = "";
        });
      }
    });
    passwordController.addListener(() {
      if (passwordController.text.isEmpty) {
        setState(() {
          errorMessage = "";
        });
      }
    });
  }

  bool isFormValid() {
    bool isValidUsername = userNameController.text.isNotEmpty;
    bool isValidPassword = passwordController.text.isNotEmpty;
    return isValidUsername && isValidPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF7DAF9C),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 21, right: 100),
                        child: Text(
                          "Nom d'utilisateur ou courriel",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 63,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: userNameController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
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
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 21,
                          right: 200,
                        ),
                        child: Text(
                          "Mot de passe",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 63,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: TextField(
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
                          onPressed: () async {
                            if (isFormValid()) {
                              Credentials credentials = Credentials(
                                username: userNameController.text,
                                password: passwordController.text,
                              );
                              String? serverErrorMessage =
                                  await formService.connect(credentials);
                              if (serverErrorMessage == null) {
                                //TODO: Change the PlaceHolder with home page when ready
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => Placeholder(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  errorMessage = serverErrorMessage;
                                });
                              }
                            } else {
                              setState(() {
                                errorMessage =
                                    "Les entrées ne devraient pas être vides";
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            backgroundColor: Color.fromARGB(255, 31, 150, 104),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Connexion"),
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
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Container(
                          child: Text(
                            "S'inscrire",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 21),
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PasswordResetPage(),
                              ),
                            );
                          },
                          child: Container(
                            child: Text(
                              "Mot de passe oublié?",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //Temporaire pour tester la page d'admin
                    Padding(
                      padding: EdgeInsets.only(top: 21),
                      child: SizedBox(
                        width: 430,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AdminPopup();
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            backgroundColor: Color.fromARGB(255, 31, 150, 104),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Ouvrir le popup"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
