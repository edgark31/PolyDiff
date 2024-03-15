// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/app_text_constants.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/utils/credentials_validation.dart';
import 'package:mobile/widgets/customs/app_style.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_text_input_field.dart';
import 'package:provider/provider.dart';

class ConnectionForm extends StatefulWidget {
  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
  final FormService formService = FormService();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).size.height * 0.3;
    final socketService = context.watch<SocketService>();
    final infoService = context.watch<InfoService>();
    final chatService = context.watch<ChatService>();
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                top: bottomPadding, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  APP_NAME_TXT,
                  style: appstyle(60, kLightOrange, FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                CustomTextInputField(
                  label: 'Nom d\'utilisateur ou courriel',
                  controller: usernameController,
                  hint: 'Entrez votre nom d\'utilisateur',
                  maxLength: 20,
                  errorText:
                      _validator.states['username'] == ValidatorState.isInvalid
                          ? "Nom d\'utilisateur ou courriel invalide"
                          : null,
                  isPassword: false,
                ),
                CustomTextInputField(
                  label: 'Mot de passe',
                  controller: passwordController,
                  hint: 'Entrez votre mot de passe',
                  errorText:
                      _validator.states['password'] == ValidatorState.isInvalid
                          ? "Mot de passe invalide"
                          : null,
                  maxLength: 20,
                  isPassword: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      press: () async {
                        if (isFormValid()) {
                          Credentials credentials = Credentials(
                            username: usernameController.text,
                            password: passwordController.text,
                          );
                          String? serverErrorMessage =
                              await formService.connect(credentials);
                          if (serverErrorMessage == null) {
                            socketService.setup(
                                SocketType.Auth, infoService.id);
                            chatService.setGlobalChatListeners();
                            Navigator.pushNamed(context, DASHBOARD_ROUTE);
                          }
                        }
                      },
                      backgroundColor: kMidOrange,
                      textColor: kLight,
                      text: SIGN_IN_BTN_TXT,
                    ),
                    SizedBox(width: 125),
                    CustomButton(
                        text: SIGN_UP_BTN_TXT,
                        press: () =>
                            Navigator.pushNamed(context, SIGN_UP_ROUTE),
                        backgroundColor: kMidGreen,
                        textColor: kLight),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
