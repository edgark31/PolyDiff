// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/register_provider.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/utils/credentials_validation.dart';
import 'package:mobile/widgets/avatar_picker.dart';
import 'package:mobile/widgets/customs/app_style.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_text_input_field.dart';
import 'package:mobile/widgets/username_generator.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FormService formService = FormService();

  ImageProvider? _selectedAvatar;
  String? _selectedAvatarId;
  String? _selectedAvatarBase64;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmationController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmationController.dispose();
    super.dispose();
  }

  int selectedLanguage = 1;
  bool hasAnimalName = false;
  bool hasNumber = false;

  String errorMessage = "";
  String usernameFormat = NO;
  String emailFormat = NO;
  String passwordStrength = '';
  String passwordConfirmation = '';

  late final CredentialsValidator _validator;

  @override
  void initState() {
    super.initState();
    _validator = CredentialsValidator(
      onStateChanged: () {
        setState(() {
          // Force the widget to rebuild with updated validation status
        });
      },
    );
    usernameController.addListener(validateUsername);
    emailController.addListener(validateEmail);
    passwordController.addListener(validatePassword);
    confirmationController.addListener(validatePasswordConfirmation);
  }

  void updateValidatorStates() {
    setState(() {
      usernameFormat =
          _validator.states['username'] == ValidatorState.isValid ? YES : NO;
      emailFormat =
          _validator.states['email'] == ValidatorState.isValid ? YES : NO;
      passwordStrength = _validator.passwordStrength;
      passwordConfirmation =
          _validator.states['passwordConfirmation'] == ValidatorState.isValid
              ? YES
              : NO;
    });
  }

  void validateUsername() {
    _validator.isValidUsername(usernameController.text);
    updateValidatorStates();
  }

  void validateEmail() {
    _validator.isValidEmail(emailController.text);
    updateValidatorStates();
  }

  void validatePassword() {
    _validator.updatePasswordStrength(passwordController.text);
    updateValidatorStates();
  }

  void validatePasswordConfirmation() {
    _validator.hasMatchingPasswords(
        passwordController.text, confirmationController.text);
    updateValidatorStates();
  }

  Future<void> _registerUserCredentials() async {
    if (!_validator.hasValidCredentials()) {
      setState(() {
        errorMessage = INVALID_FORM_INPUTS;
      });
      return;
    }
    await _onRegister();
  }

  Future<void> _onRegister() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String email = emailController.text.trim();

    SignUpCredentialsBody credentialsBody = SignUpCredentialsBody(
        credentials: Credentials(
      username: username,
      password: password,
      email: email,
    ));

    if (_selectedAvatarId != null) {
      RegisterProvider registerProvider =
          Provider.of<RegisterProvider>(context, listen: false);

      await registerProvider.postCredentialsData(credentialsBody);

      if (registerProvider.isBack) {
        UploadAvatarBody predefinedAvatarBody =
            UploadAvatarBody(username: username, id: _selectedAvatarId!);
        await registerProvider.putAvatarData(
            predefinedAvatarBody, AvatarType.predefined);

        if (registerProvider.isBack) Navigator.pushNamed(context, LOGIN_ROUTE);
      } else if (_selectedAvatarBase64 != null) {
        UploadAvatarBody avatarBody = UploadAvatarBody(
            username: username, base64Avatar: _selectedAvatarBase64!);

        await registerProvider.putAvatarData(avatarBody, AvatarType.camera);
      }
    }
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
                child: Text(SIGN_UP_BTN_TXT,
                    style: appstyle(24, kMidOrange, FontWeight.bold)),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildSelectedAvatar(),
                    SizedBox(width: 100),
                    buildAvatarPicker(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(child: buildFieldsWithGenerator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFieldsWithGenerator() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildUsernameField(),
              buildEmailField(),
              buildPasswordField(),
              buildPasswordConfirmationField(),
              buildSubmitButton(),
              buildLoginLink(),
            ],
          ),
        ),
        Positioned(
          top: 20,
          right: 200,
          child: UsernameGenerator(onUsernameGenerated: (generatedName) {
            usernameController.text = generatedName;
            validateUsername();
          }),
        ),
      ],
    );
  }

  Widget buildSubmitButton() {
    return Center(
      child: Column(
        children: [
          CustomButton(
              press: () => _registerUserCredentials(),
              backgroundColor: kMidOrange,
              text: SIGN_UP_BTN_TXT)
        ],
      ),
    );
  }

  Widget buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Nom d'utilisateur",
          controller: usernameController,
          hint: "Entrez votre nom d'utilisateur",
          helperText: 'Non vide: $usernameFormat',
          errorText: _validator.states['username'] == ValidatorState.isInvalid
              ? "Nom d'utilisateur requis"
              : null,
          maxLength: 20,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Email",
          controller: emailController,
          hint: "ex: john.doe@gmail.com",
          helperText: 'Format valide requis: $emailFormat',
          errorText: _validator.states['email'] == ValidatorState.isInvalid
              ? "Courriel requis ou invalide"
              : null,
          maxLength: 40,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Mot de passe",
          controller: passwordController,
          hint: "Entrez votre mot de passe",
          helperText: 'Force du mot de passe: $passwordStrength',
          errorText: _validator.states['password'] == ValidatorState.isInvalid
              ? "Mot de passe requis"
              : null,
          maxLength: 20,
          isPassword: true,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildPasswordConfirmationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInputField(
          label: "Confirmation du mot de passe",
          controller: confirmationController,
          hint: "Confirmez votre mot de passe",
          helperText:
              'Doit correspondre au mot de passe: $passwordConfirmation',
          maxLength: 40,
          errorText: _validator.states['passwordConfirmation'] ==
                  ValidatorState.isInvalid
              ? "Les mots de passes doivent être identiques"
              : null,
          isPassword: true,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildLoginLink() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, LOGIN_ROUTE),
          child: Text(
            "Se connecter",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGreen),
          ),
        ),
      ),
    );
  }

  Widget buildSelectedAvatar() {
    return CircleAvatar(
      backgroundImage: _selectedAvatar,
      radius: 50,
      backgroundColor: Colors.grey.shade200,
      child: _selectedAvatar == null ? Icon(Icons.person, size: 50) : null,
    );
  }

  void setPredefinedAvatarSelection(String id) {
    _selectedAvatarId = id;
  }

  void setCameraAvatarSelection(String base64) {
    _selectedAvatarBase64 = base64;
  }

  Widget buildAvatarPicker() {
    return AvatarPicker(
      onAvatarSelected: (ImageProvider image, {String? id, String? base64}) {
        if (id != null) {
          // predefined avatar selected
          setPredefinedAvatarSelection(id);
        } else if (base64 != null) {
          // camera image selected
          setCameraAvatarSelection(base64);
        }
        // update UI, no upload required
        setState(() {
          _selectedAvatar = image;
        });
      },
    );
  }
}
