import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/widgets/change_password_popup.dart';

class PasswordResetPopup extends StatefulWidget {
  @override
  State<PasswordResetPopup> createState() => _PasswordResetPopupState();
}

class _PasswordResetPopupState extends State<PasswordResetPopup> {
  final FormService formService = Get.find();
  TextEditingController emailController = TextEditingController();

  String errorMessage = "";
  bool isCodeAsked = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      if (emailController.text.isEmpty) {
        setState(() {
          errorMessage = "";
        });
      }
    });
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
                image: AssetImage('assets/images/raccoon cafe.jpeg'),
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
                  "Récuperation de mot de passe",
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
                    isCodeAsked ? "Entrer le code" : "Courriel",
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
                      controller: emailController,
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
                    child: isCodeAsked
                        ? codeButton(context)
                        : emailButton(context),
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

  Widget codeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print('text is ${emailController.text}');
        try {
          print('trying to parse the int');
          int.parse(emailController.text);
        } catch (e) {
          print('catch entered');
          setState(() {
            emailController.text = "";
            errorMessage = "Le code doit être un nombre à 4 chiffres";
          });
        }
        print('try-catch passed code is ${int.parse(emailController.text)}');
        if (formService.checkCode(int.parse(emailController.text))) {
          print('Code valide');
          setState(() {
            emailController.text = "";
            Navigator.of(context).pop();
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return ChangePasswordPopup();
              },
            );
          });
        } else {
          setState(() {
            emailController.text = "";
            errorMessage = "Code invalide";
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
      child: Text("Valider mon code"),
    );
  }

  Widget emailButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String? serverErrorMessage =
            await formService.sendMail(emailController.text);

        if (serverErrorMessage == null) {
          setState(() {
            emailController.text = "";
            isCodeAsked = true;
          });
        } else {
          print('Erreur serveur');
          print(serverErrorMessage);
          setState(() {
            errorMessage = "Il n'y a pas de compte associé à cet email";
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
      child: Text("Recevoir un code"),
    );
  }
}
