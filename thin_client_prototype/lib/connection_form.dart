import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';
import 'services/socket_service.dart';

class ConnectionForm extends StatefulWidget {
  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController ipAddressController = TextEditingController();
  String errorMessage = "";
  final regexIP = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$'); // IP address regex

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
    final socketService = context.watch<SocketService>();
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    socketService.socketStatus ? 'Socket ON' : 'Socket OFF',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  Text(
                    socketService.connectionStatus
                        ? 'Username OK'
                        : 'Disconnected',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      socketService.disconnect();
                    },
                    child: Text("Se Déconnecter"),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20, right: 100),
                      child: Text(
                        "Entrez l'adresse IP du serveur (Adresse : ${socketService.ip})",
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
                        controller: ipAddressController,
                        decoration: InputDecoration(
                          hintText: "Adresse",
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
                        String ipAddress = ipAddressController.text;
                        if (regexIP.hasMatch(ipAddress)) {
                          print(
                              "Sending the server the address : " + ipAddress);
                          socketService.setIP(ipAddress);
                        } else {
                          setState(() {
                            errorMessage =
                                "Le format de l'adresse est invalide";
                          });
                        }
                        // Future.delayed(Duration(milliseconds: 200), () {
                        //   if (socketService.connectionStatus) {
                        //     print("Connection approved");
                        //     Navigator.of(context).push(
                        //       MaterialPageRoute(
                        //         builder: (context) => ChatPage(),
                        //       ),
                        //     );
                        //   } else if (userName.isNotEmpty) {
                        //     setState(() {
                        //       errorMessage =
                        //           "Ce compte est déjà connecté dans un autre client";
                        //     });
                        //   }
                        // });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        backgroundColor: Color.fromARGB(255, 31, 150, 104),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Entrer l'adresse IP"),
                    ),
                  ),
                  Text(
                    ipAddressController.text.isEmpty
                        ? "Vous devez entrer une adresse IP"
                        : regexIP.hasMatch(ipAddressController.text)
                            ? ""
                            : "Le format de l'adresse est invalide",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 240, 16, 0),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20, right: 100),
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
                        if (userName.isNotEmpty &&
                            socketService.ip.isNotEmpty) {
                          print(
                              "Sending the server your username: " + userName);
                          socketService.checkName(userName);
                        } else {
                          setState(() {
                            errorMessage =
                                "Votre nom ne peut pas être vide et vous devez entrer une adresse IP";
                          });
                        }
                        Future.delayed(Duration(milliseconds: 200), () {
                          if (socketService.connectionStatus) {
                            print("Connection approved");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatPage(),
                              ),
                            );
                          } else if (userName.isNotEmpty) {
                            setState(() {
                              errorMessage =
                                  "Ce compte est déjà connecté dans un autre client";
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
