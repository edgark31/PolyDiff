// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/credentials.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/avatar_picker.dart';
import 'package:mobile/widgets/customs/custom_text_input_field.dart';
import 'package:mobile/widgets/username_generator.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FormService formService = FormService('http://localhost:3000');
  ImageProvider? _selectedAvatar;

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();
  String errorMessage = "";
  int selectedLanguage = 1;
  bool hasAnimalName = false;
  bool hasNumber = false;

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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'Inscription',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kMidOrange),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildSelectedAvatar(),
                    SizedBox(width: 100),
                    _buildAvatarPicker(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(child: _buildFieldsWithGenerator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldsWithGenerator() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUsernameField(),
              _buildEmailField(),
              _buildPasswordField(),
              _buildPasswordConfirmationField(),
              _buildSubmitButton(),
              _buildLoginLink(),
            ],
          ),
        ),
        Positioned(
          top: 20,
          right: 200,
          child: UsernameGenerator(onUsernameGenerated: (generatedName) {
            userNameController.text = generatedName;
            isUsernameValid(userNameController.text);
          }),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final socketService = context.watch<SocketService>();
    return Center(
      child: Column(
        children: [
          Text(
            errorMessage,
            style: TextStyle(
                color: const Color.fromARGB(255, 240, 16, 0),
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isFormValid()) {
                Credentials credentials = Credentials(
                  username: userNameController.text,
                  password: passwordController.text,
                  email: emailController.text,
                );
                //TODO: Change the id to the avatar's id when ready
                String? serverErrorMessage =
                    await formService.register(credentials, "1");
                if (serverErrorMessage == null) {
                  Navigator.pushNamed(context, LOGIN_ROUTE);
                } else {
                  setState(() {
                    errorMessage = serverErrorMessage;
                  });
                }
              } else {
                setState(() {
                  errorMessage =
                      "Une ou plusieurs entrée(s) est/sont incorrecte(s)";
                });
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: kLight,
              backgroundColor: kLightOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text('Inscription'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Nom d'utilisateur",
          controller: userNameController,
          hint: "Entrez votre nom d'utilisateur",
          onInputTextChanged: isUsernameValid,
          helperText: 'Non vide: $usernameFormat',
          maxLength: 20,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Email",
          controller: emailController,
          hint: "ex: john.doe@gmail.com",
          onInputTextChanged: isEmailValid,
          helperText: 'Format valide requis: $emailFormat',
          maxLength: 40,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Mot de passe",
          controller: passwordController,
          hint: "Entrez votre mot de passe",
          onInputTextChanged: updatePasswordStrength,
          helperText: 'Force du mot de passe: $passwordStrength',
          maxLength: 40,
          isPassword: true,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordConfirmationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Confirmation du mot de passe",
          controller: confirmationController,
          hint: "Confirmez votre mot de passe",
          onInputTextChanged: updateConfirmation,
          helperText:
              'Doit correspondre au mot de passe: $passwordConfirmation',
          maxLength: 40,
          isPassword: true,
        ),
        SizedBox(height: 10),
      ],
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

  Widget _buildSelectedAvatar() {
    return CircleAvatar(
      backgroundImage: _selectedAvatar,
      radius: 50,
      backgroundColor: Colors.grey.shade200,
      child: _selectedAvatar == null ? Icon(Icons.person, size: 50) : null,
    );
  }

  Widget _buildAvatarPicker() {
    return AvatarPicker(
      onAvatarSelected: (ImageProvider image) {
        setState(() {
          _selectedAvatar = image;
        });
      },
    );
  }
}
