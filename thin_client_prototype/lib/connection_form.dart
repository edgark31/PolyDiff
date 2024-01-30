import 'package:flutter/material.dart';

import 'chat_page.dart';

class ConnectionForm extends StatefulWidget {
  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
  TextEditingController userNameController = TextEditingController();
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
    return Container(
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
                      padding: EdgeInsets.only(top: 210, right: 100),
                      child: Text(
                        "Entrez votre nom d'utilisateur",
                        style: TextStyle(
                          fontSize: 20,
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
                        decoration: InputDecoration(
                          hintText: "Nom d'utilisateur",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 430,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        String userName = userNameController.text;
                        if (userName.isNotEmpty) {
                          print(
                              "Sending the server your username: " + userName);
                        } else {
                          setState(() {
                            errorMessage = "";
                          });
                        }

                        if (userName == "raccoon") {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatPage(),
                            ),
                          );
                        } else {
                          setState(() {
                            errorMessage =
                                "Ce nom d'utilisateur existe présentement";
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
                  Text(
                    errorMessage,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 240, 16, 0),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
