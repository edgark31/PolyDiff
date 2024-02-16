import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../pages/login_page.dart';
import '../services/name_generation_service.dart';
import '../services/socket_service.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();
  String errorMessage = "";
  int selectedLanguage = 1;
  bool hasAnimalName = false;
  bool hasNumber = false;

  bool isFormValid = false;
  String usernameError = '';
  String emailError = '';
  String passwordError = '';
  String confirmationError = '';
  String passwordStrength = '';

  bool isUsernameValid(String username) {
    return username.isNotEmpty;
  }

  bool isEmailValid(String email) {
    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        emailError = "Le format de l'adresse e-mail est incorrect";
      });
      return false;
    } else {
      setState(() {
        emailError = '';
      });
      return true;
    }
  }

  bool arePasswordsMatching(String password, String confirmation) {
    return password == confirmation;
  }

  void updatePasswordStrength(String password) {
    String strength = '';
    if (RegExp(r'[a-zA-Z0-9]').hasMatch(password) && password.length < 10) {
      strength = 'Faible';
    } else if (password.length >= 10 || RegExp(r'[$,!,&]').hasMatch(password)) {
      if (password.length > 10 && RegExp(r'[$,!,&]').hasMatch(password)) {
        strength = 'Élevé';
      } else {
        strength = 'Moyen';
      }
    } else {
      strength = 'Faible';
    }
    setState(() {
      passwordStrength = strength;
    });
  }

  void updateButtonState() {
    bool isValidUsername = isUsernameValid(userNameController.text);
    bool isValidEmail = isEmailValid(emailController.text);
    bool isValidPassword = arePasswordsMatching(
        passwordController.text, confirmationController.text);

    setState(() {
      isFormValid = isValidUsername && isValidEmail && isValidPassword;
    });
  }

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
    final nameGenerationService = NameGenerationService();
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
                      'Inscription',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 21, right: 225),
                              child: Text(
                                "Nom d'utilisateur",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 21, right: 290),
                              child: Text(
                                "Courriel",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
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
                                  helperText: 'Non vide et unique',
                                  filled: true,
                                  fillColor: Colors.white,
                                  helperStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: emailController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(40),
                              ],
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  helperText: 'Non vide',
                                  hintText: 'ex: john.doe@gmail.com',
                                  filled: true,
                                  fillColor: Colors.white,
                                  helperStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 70,
                          ),
                          child: Text(
                            "Générer un nom d'utilisateur: ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: ListTile(
                            title: const Text(
                              'En français',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: Radio(
                              value: 1,
                              groupValue: selectedLanguage,
                              onChanged: (value) {
                                setState(() {
                                  selectedLanguage = value!;
                                  print("Button value: $selectedLanguage");
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: ListTile(
                            title: const Text(
                              'En Anglais',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: Radio(
                              value: 2,
                              groupValue: selectedLanguage,
                              onChanged: (value) {
                                setState(() {
                                  selectedLanguage = value!;
                                  print("Button value: $selectedLanguage");
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 100,
                        ),
                        child: SizedBox(
                          width: 300,
                          height: 50,
                          child: CheckboxListTile(
                            title: const Text(
                              "Contenant le nom d'un animal",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: hasAnimalName,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value != null) {
                                  setState(() {
                                    hasAnimalName = value;
                                    print(hasAnimalName);
                                  });
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        height: 50,
                        child: CheckboxListTile(
                          title: const Text(
                            "Contenant des chiffres",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: hasNumber,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null) {
                                setState(() {
                                  hasNumber = value;
                                  print(hasNumber);
                                });
                              }
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_suggest),
                        onPressed: () {
                          nameGenerationService.generateName(
                              selectedLanguage, hasAnimalName, hasNumber);
                          userNameController.text =
                              nameGenerationService.generatedName;
                        },
                        iconSize: 50,
                      ),
                    ]),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 21,
                                right: 250,
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
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 21,
                                right: 130,
                              ),
                              child: Text(
                                "Confirmation du mot de passe",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: passwordController,
                              onChanged: (String newPassword) =>
                                  updatePasswordStrength(newPassword),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(40),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                helperText:
                                    'Force du mot de passe: $passwordStrength',
                                filled: true,
                                fillColor: Colors.white,
                                helperStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: confirmationController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(40),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                helperText: 'Doit correspondre au mot de passe',
                                filled: true,
                                fillColor: Colors.white,
                                helperStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 21),
                        child: SizedBox(
                          width: 430,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: isFormValid
                                ? () {
                                    // TODO: ajouter la vérification
                                    // TODO optionnel: rendre ca clean pas if if if if
                                    String userName = userNameController.text;
                                    if (userName.isNotEmpty) {
                                      print(
                                          "Sending the server your username: " +
                                              userName);
                                      socketService.checkName(userName);
                                    } else {
                                      setState(() {
                                        errorMessage =
                                            "Votre nom ne peut pas être vide";
                                      });
                                    }
                                    Future.delayed(Duration(milliseconds: 300),
                                        () {
                                      print(
                                          "Connection status: ${socketService.connectionStatus}");
                                      if (socketService.connectionStatus) {
                                        print(
                                            "We are in the connection status");
                                        print("Connection approved");
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => LoginPage(),
                                          ),
                                        );
                                      } else if (userName.isNotEmpty) {
                                        setState(() {
                                          errorMessage =
                                              "Un client avec ce nom existe déjà";
                                        });
                                      }
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              backgroundColor:
                                  Color.fromARGB(255, 31, 150, 104),
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Inscription"),
                          ),
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
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
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
