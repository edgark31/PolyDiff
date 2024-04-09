// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/services/friend_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/utils/credentials_validation.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_text_input_field.dart';
import 'package:mobile/widgets/customs/stroked_text_widget.dart';
import 'package:mobile/widgets/password_reset_popup.dart';
import 'package:provider/provider.dart';

class SignInForm extends StatefulWidget {
  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final FormService formService = Get.find();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? serverErrorMessage;
  String usernameFormat = NO;
  String emailFormat = NO;
  String passwordFormat = NO;

  late final CredentialsValidator _validator;

  @override
  void initState() {
    super.initState();
    _validator = CredentialsValidator(
      onStateChanged: () {
        setState(() {
          // Force the widget to rebuild with updated Validator status
        });
      },
    );
    usernameController.addListener(validateUsername);
    passwordController.addListener(validatePassword);
  }

  void updateValidatorStates() {
    setState(() {
      usernameFormat =
          _validator.states['username'] == ValidatorState.isValid ? YES : NO;
      _validator.states['password'] == ValidatorState.isValid ? YES : NO;
    });
  }

  void validateUsername() {
    _validator.isValidUsername(usernameController.text);
    updateValidatorStates();
  }

  void validatePassword() {
    _validator.updatePasswordStrength(passwordController.text);
    updateValidatorStates();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isFormValid() {
    bool isValidUsername = usernameController.text.isNotEmpty;
    bool isValidPassword = passwordController.text.isNotEmpty;
    return isValidUsername && isValidPassword;
  }

  @override
  Widget build(BuildContext context) {
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();
    final chatService = context.watch<ChatService>();
    final AvatarProvider avatarProvider = context.watch<AvatarProvider>();
    final FriendService friendService = Get.find();
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                StrokedTextWidget(
                  text: APP_NAME_TXT,
                  textStyle: TextStyle(
                    fontFamily: 'troika',
                    fontSize: 140,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8A430),
                    letterSpacing: 0.0,
                  ),
                ),
                SizedBox(height: 40),
                CustomTextInputField(
                  label: 'Nom d\'utilisateur ou courriel',
                  controller: usernameController,
                  hint: 'Entrez votre nom d\'utilisateur',
                  maxLength: 40,
                  errorText:
                      _validator.states['username'] == ValidatorState.isEmpty
                          ? "Nom d\'utilisateur ou courriel requis"
                          : _validator.states['username'] ==
                                  ValidatorState.isInvalid
                              ? "Nom d\'utilisateur ou courriel invalide"
                              : null,
                  isPassword: false,
                ),
                CustomTextInputField(
                  label: 'Mot de passe',
                  controller: passwordController,
                  hint: 'Entrez votre mot de passe',
                  errorText:
                      _validator.states['password'] == ValidatorState.isEmpty
                          ? "Mot de passe requis"
                          : _validator.states['password'] ==
                                  ValidatorState.isInvalid
                              ? "Mot de passe invalide"
                              : null,
                  maxLength: 20,
                  isPassword: true,
                ),
                CustomButton(
                  press: () async {
                    if (isFormValid()) {
                      Credentials credentials = Credentials(
                        username: usernameController.text,
                        password: passwordController.text,
                      );
                      String? newServerErrorMessage =
                          await formService.connect(credentials);
                      setState(() {
                        serverErrorMessage = newServerErrorMessage;
                      });
                      if (serverErrorMessage == null) {
                        socketService.setup(SocketType.Auth, infoService.id);
                        friendService.setListeners();
                        chatService.setupGlobalChat();
                        avatarProvider.setAccountAvatarUrl();
                        Navigator.pushNamed(context, DASHBOARD_ROUTE);
                      }
                    }
                  },
                  text: SIGN_IN_BTN_TXT,
                ),
                if (serverErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      serverErrorMessage!,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                CustomButton(
                  press: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return PasswordResetPopup();
                      },
                    );
                  },
                  text: FORGOT_PASSWORD_TXT,
                ),
                CustomButton(
                  text: SIGN_UP_BTN_TXT,
                  press: () => Navigator.pushNamed(context, SIGN_UP_ROUTE),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
