import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/services/services.dart';
import 'package:mobile/widgets/widgets.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final nameGenerationService = NameGenerationService();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();
  String errorMessage = "";

  String usernameFormat = 'Non';
  String emailFormat = 'Non';
  String passwordStrength = '';
  String passwordConfirmation = '';

  bool isUsernameValid(String username) {
    if (username.isNotEmpty) {
      setState(() {
        usernameFormat = "Oui";
      });
      return true;
    } else {
      setState(() {
        usernameFormat = "Non";
      });
      return false;
    }
  }

  // TODO : create a service to reuse in connexion form
  bool isEmailValid(String email) {
    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (emailRegex.hasMatch(email) && email.isNotEmpty) {
      setState(() {
        emailFormat = "Oui";
      });
      return true;
    } else {
      setState(() {
        emailFormat = 'Non';
      });
      return false;
    }
  }

  bool arePasswordsMatching(String password, String confirmation) {
    return (password == confirmation &&
        password.isNotEmpty &&
        confirmation.isNotEmpty);
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
    updateConfirmation(confirmationController.text);
  }

  void updateConfirmation(String confirmation) {
    if (arePasswordsMatching(passwordController.text, confirmation)) {
      setState(() {
        passwordConfirmation = 'Oui';
      });
    } else {
      setState(() {
        passwordConfirmation = 'Non';
      });
    }
  }

  bool isFormValid() {
    bool isValidUsername = isUsernameValid(userNameController.text);
    bool isValidEmail = isEmailValid(emailController.text);
    bool isValidPassword = arePasswordsMatching(
        passwordController.text, confirmationController.text);
    return isValidUsername && isValidEmail && isValidPassword;
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inscription',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: kMidOrange,
                ),
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: CustomTextInputField(
                      label: "Nom d'utilisateur",
                      controller: userNameController,
                      hint: "Entrez votre nom d'utilisateur",
                      onInputTextChanged: isUsernameValid,
                      helperText: 'Non vide: $usernameFormat',
                      maxLength: 20,
                    ),
                  ),
                  SizedBox(width: 100),
                  Flexible(
                    child: CustomTextInputField(
                      label: "Courriel",
                      controller: emailController,
                      hint: 'ex: john.doe@gmail.com',
                      onInputTextChanged: isEmailValid,
                      helperText: 'Non vide et suit le format: $emailFormat',
                      maxLength: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: UsernameGenerator(
                  onUsernameGenerated: (generatedName) {
                    userNameController.text = generatedName;
                    isUsernameValid(userNameController.text);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: CustomTextInputField(
                      label: "Mot de passe",
                      controller: passwordController,
                      hint: 'Entrez votre mot de passe',
                      onInputTextChanged: updatePasswordStrength,
                      helperText: 'Force du mot de passe: $passwordStrength',
                      maxLength: 40,
                      isPassword: true,
                    ),
                  ),
                  SizedBox(width: 100),
                  Flexible(
                    child: CustomTextInputField(
                      label: "Confirmation du mot de passe",
                      controller: confirmationController,
                      hint: "Confirmez votre mot de passe",
                      onInputTextChanged: updateConfirmation,
                      helperText:
                          'Correspondent et non-vide: $passwordConfirmation',
                      maxLength: 40,
                      isPassword: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              _buildSubmitButton(),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (isFormValid()) {
            // TODO: Send the new account created
          } else {
            setState(() => errorMessage =
                "Une ou plusieurs entrée(s) est/sont incorrecte(s)");
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: kLight,
          backgroundColor: kLightOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text('Inscription'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            "Se connecter",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGreen),
          ),
        ),
      ),
    );
  }
}
