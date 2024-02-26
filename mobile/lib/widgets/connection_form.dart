import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/services.dart';
import 'package:mobile/widgets/customs/app_style.dart';
import 'package:provider/provider.dart';

class ConnectionForm extends StatefulWidget {
  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
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
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).size.height * 0.48;
    final socketService = context.watch<SocketService>();
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                top: bottomPadding, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "PolyDiff",
                  style: appstyle(60, kLightOrange, FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
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
                SizedBox(
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
                SizedBox(
                  width: 400,
                  height: 63,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: passwordController,
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
                Padding(
                  padding: EdgeInsets.only(top: 21),
                  child: SizedBox(
                    width: 430,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: ajouter la vérification et l'envoit du mot de passe
                        // TODO optionnel: rendre ca clean pas if if if if
                        String userName = userNameController.text;
                        if (userName.isNotEmpty) {
                          print("Sending the server your username: $userName");
                          socketService.checkName(userName);
                        } else {
                          setState(() {
                            errorMessage = "Votre nom ne peut pas être vide";
                          });
                        }
                        Future.delayed(Duration(milliseconds: 300), () {
                          print(
                              "Connection status: ${socketService.connectionStatus}");
                          if (socketService.connectionStatus) {
                            print("We are in the connection status");
                            print("Connection approved");
                            Navigator.pushNamed(context, CHAT_ROUTE);
                          } else if (userName.isNotEmpty) {
                            setState(() {
                              errorMessage =
                                  "Un client avec ce nom existe déjà";
                            });
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        backgroundColor: Color.fromARGB(255, 31, 150, 104),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("C O N N E X I O N"),
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
                      Navigator.pushNamed(context, SIGNUP_ROUTE);
                    },
                    child: Container(
                      child: Text(
                        "S' I N S C R I R E",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
