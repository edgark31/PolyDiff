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
                    child: _buildTextInputField(
                      label: "Nom d'utilisateur",
                      controller: userNameController,
                      hint: 'Entrez votre nom d\'utilisateur',
                      maxLength: 20,
                    ),
                  ),
                  SizedBox(width: 100),
                  Flexible(
                    child: _buildTextInputField(
                      label: "Courriel",
                      controller: emailController,
                      hint: 'ex: john.doe@gmail.com',
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
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: _buildTextInputField(
                      label: "Mot de passe",
                      controller: passwordController,
                      hint: 'Entrez votre mot de passe',
                      maxLength: 40,
                      isPassword: true,
                    ),
                  ),
                  SizedBox(width: 100),
                  Flexible(
                    child: _buildTextInputField(
                      label: "Confirmation du mot de passe",
                      controller: confirmationController,
                      hint: 'Confirmez votre mot de passe',
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

  Widget _buildTextInputField(
      {required String label,
      required TextEditingController controller,
      required String hint,
      int maxLength = 20,
      bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          maxLength: maxLength,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Colors.orange, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.grey[200],
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
        child: Text('Inscription'),
        style: ElevatedButton.styleFrom(
          foregroundColor: kLight,
          backgroundColor: kLightOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 16),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Text(
            "Se connecter",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: kMidGreen),
          ),
        ),
      ),
    );
  }
}
