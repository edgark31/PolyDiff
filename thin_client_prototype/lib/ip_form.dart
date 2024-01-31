import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'connection_form.dart';
import 'services/socket_service.dart';

class IPForm extends StatefulWidget {
  @override
  State<IPForm> createState() => _IPForm();
}

class _IPForm extends State<IPForm> {
  TextEditingController ipAddressController = TextEditingController();
  String errorMessage = "";
  final regexIP = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$'); // IP address regex

  @override
  void initState() {
    super.initState();
    ipAddressController.addListener(() {
      if (ipAddressController.text.isEmpty) {
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
                children: [
                  Text(
                    'Adresse IP du serveur',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20, right: 100),
                      child: Text(
                        "Entrez l'adresse IP du serveur",
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
                          hintText:
                              "Adresse IP selon le format XXX.XXX.XXX.XXX",
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
                        if (ipAddress.isEmpty) {
                          setState(() {
                            errorMessage = "L'adresse IP ne peut pas être vide";
                          });
                        } else if (!regexIP.hasMatch(ipAddress)) {
                          setState(() {
                            errorMessage =
                                "Le format de l'adresse est invalide";
                          });
                        } else {
                          socketService.setIP(ipAddress);
                          setState(() {
                            errorMessage =
                                "En attente de la réponse du serveur";
                          });
                          Future.delayed(Duration(milliseconds: 1000), () {
                            if (socketService.hasClientEverConnected) {
                              print(
                                  "Sending the server the address : $ipAddress");
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ConnectionForm(),
                                ),
                              );
                            } else {
                              setState(() {
                                errorMessage =
                                    "La connexion n'a pas pu être établie. Veuillez réessayer une autre adresse.";
                              });
                            }
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
                      child: Text("Entrer l'adresse IP"),
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
