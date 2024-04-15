// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/register_provider.dart';
import 'package:mobile/services/avatar_service.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/utils/credentials_validation.dart';
import 'package:mobile/widgets/avatar_picker.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_text_input_field.dart';
import 'package:mobile/widgets/username_generator.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FormService formService = Get.find();

  ImageProvider _selectedAvatar = NetworkImage(getDefaultAvatarUrl('1'));
  String _selectedAvatarId = '1';
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

  String? serverErrorMessage;
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
        serverErrorMessage = INVALID_FORM_INPUTS;
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

    print('_selectedAvatarId $_selectedAvatarId');
    print('_selectedAvatarBase64 $_selectedAvatarBase64');

    RegisterProvider registerProvider =
        Provider.of<RegisterProvider>(context, listen: false);

    serverErrorMessage =
        await registerProvider.postCredentialsData(credentialsBody);
    setState(() {});

    if (registerProvider.isBack) {
      if (_selectedAvatarBase64 != null) {
        UploadAvatarBody avatarBody = UploadAvatarBody(
            username: username, base64Avatar: _selectedAvatarBase64!);

        serverErrorMessage =
            await registerProvider.putAvatarData(avatarBody, AvatarType.camera);
        setState(() {});
      } else {
        UploadAvatarBody predefinedAvatarBody =
            UploadAvatarBody(username: username, defaultId: _selectedAvatarId);
        serverErrorMessage = await registerProvider.putAvatarData(
            predefinedAvatarBody, AvatarType.predefined);
        setState(() {});
      }

      if (registerProvider.isBack) {
        Navigator.pushNamed(context, SIGN_IN_ROUTE);
      }
    }
    //  else if (_selectedAvatarBase64 != null) {
    //   UploadAvatarBody avatarBody = UploadAvatarBody(
    //       username: username, base64Avatar: _selectedAvatarBase64!);

    //   await registerProvider.putAvatarData(avatarBody, AvatarType.camera);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: buildFieldsWithGenerator(),
        ),
      ),
    );
  }

  Widget buildFieldsWithGenerator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildSelectedAvatar(),
              SizedBox(height: 30),
              Container(
                width: 450,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: kLight,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
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
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildAvatarPicker(),
              SizedBox(height: 30),
              UsernameGenerator(onUsernameGenerated: (generatedName) {
                usernameController.text = generatedName;
                validateUsername();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSubmitButton() {
    return Center(
      child: Column(
        children: [
          CustomButton(
              press: () => _registerUserCredentials(), text: SIGN_UP_BTN_TXT),
          if (serverErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                serverErrorMessage!,
                textAlign: TextAlign.center,
              ),
            ),
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
          errorText: _validator.states['username'] == ValidatorState.isEmpty
              ? "Nom d'utilisateur requis"
              : _validator.states['username'] == ValidatorState.isInvalid
                  ? "Format invalide"
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
          label: "Adresse courriel",
          controller: emailController,
          hint: "ex: john.doe@gmail.com",
          helperText: 'Format valide requis: $emailFormat',
          errorText: _validator.states['email'] == ValidatorState.isEmpty
              ? "Adresse courriel requise"
              : _validator.states['email'] == ValidatorState.isInvalid
                  ? "Format est invalide"
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
          errorText: _validator.states['password'] == ValidatorState.isEmpty
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
          maxLength: 20,
          errorText: _validator.states['passwordConfirmation'] ==
                  ValidatorState.isEmpty
              ? "Veuillez confirmer votre mot de passe"
              : _validator.states['passwordConfirmation'] ==
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
        child: CustomButton(
          text: SIGN_IN_BTN_TXT,
          press: () => Navigator.pushNamed(context, SIGN_IN_ROUTE),
        ),
      ),
    );
  }

  Widget buildSelectedAvatar() {
    return Container(
        width: 100, // Total diameter including border
        height: 100, // Total diameter including border
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200, // Background color inside the border
          border: Border.all(
            color: Colors.green, // Border color based on condition
            width: 4, // Border width
          ),
        ),
        child: CircleAvatar(
          backgroundImage: _selectedAvatar,
          radius: 50,
          backgroundColor: Colors.grey.shade200,
        ));
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
          setPredefinedAvatarSelection(id);
        } else if (base64 != null) {
          setCameraAvatarSelection(base64);
        }
        // Updates the UI
        setState(() {
          _selectedAvatar = image;
        });
      },
    );
  }
}
