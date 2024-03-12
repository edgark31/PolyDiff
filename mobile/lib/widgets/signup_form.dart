// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/avatar_service.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/widgets/avatar_picker.dart';
import 'package:mobile/widgets/customs/custom_text_input_field.dart';
import 'package:mobile/widgets/username_generator.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FormService formService = FormService();

  // Avatar
  AvatarService _avatarService = AvatarService();
  ImageProvider? _selectedAvatar;
  String? _selectedAvatarId;
  String? _selectedAvatarBase64;

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

  Future<void> _registerUser() async {
    // Check if the form is valid before proceeding
    if (!isFormValid()) {
      setState(() {
        errorMessage = "Une ou plusieurs entrée(s) est/sont incorrecte(s)";
      });
      return;
    }

    // Prepare credentials from form inputs
    final credentials = Credentials(
      username: userNameController.text,
      password: passwordController.text,
      email: emailController.text,
    );

    // Initialize error messages
    String? avatarErrorMessage;
    String? serverErrorMessage;

    // Handle registration based on avatar selection or upload
    if (_selectedAvatarId != null) {
      // Pre-selected avatar case
      serverErrorMessage =
          await formService.register(credentials, _selectedAvatarId!);
    } else if (_selectedAvatarBase64 != null) {
      // Avatar upload case: Register with a temporary ID then upload the avatar
      const tempsId = "1";
      serverErrorMessage = await formService.register(credentials, tempsId);

      if (serverErrorMessage == null) {
        avatarErrorMessage = await _avatarService.uploadCameraImage(
          credentials.username,
          _selectedAvatarBase64!,
        );
      }
    } else {
      // No avatar selected case
      avatarErrorMessage = "avatar non sélectionné";
    }

    // Navigate to login on successful registration and avatar handling, else show error
    if (serverErrorMessage == null && avatarErrorMessage == null) {
      Navigator.pushNamed(context, LOGIN_ROUTE);
    } else {
      setState(() {
        errorMessage =
            serverErrorMessage ?? avatarErrorMessage ?? "An error occurred";
      });
    }
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
    Future.microtask(() {
      AvatarProvider.setInitialAvatar();
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
            onPressed: () => _registerUser(),
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
      onAvatarSelected: (ImageProvider image, {String? id, String? base64}) {
        if (id != null) {
          // predefined avatar selected
          _setPredefinedAvatarSelection(id);
        } else if (base64 != null) {
          // camera image selected
          _setCameraAvatarSelection(base64);
        }
        // update UI, no upload required
        setState(() {
          _selectedAvatar = image;
        });
      },
    );
  }

  void _setPredefinedAvatarSelection(String id) {
    _selectedAvatarId = id;
  }

  void _setCameraAvatarSelection(String base64) {
    _selectedAvatarBase64 = base64;
  }
}
