// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/chat_service.dart';
import 'package:mobile/services/form_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/socket_service.dart';
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
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

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
    passwordController.addListener(() {
      if (passwordController.text.isEmpty) {
        setState(() {
          errorMessage = "";
        });
      }
    });
  }

  bool isFormValid() {
    bool isValidUsername = userNameController.text.isNotEmpty;
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
                  "PolyDiff",
                  style: appstyle(60, kLightOrange, FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                CustomTextInputField(
                  label: 'Nom d\'utilisateur ou courriel',
                  controller: userNameController,
                  hint: 'Entrez votre nom d\'utilisateur',
                  maxLength: 20,
                  isPassword: false,
                ),
                CustomTextInputField(
                  label: 'Mot de passe',
                  controller: passwordController,
                  hint: 'Entrez votre mot de passe',
                  maxLength: 20,
                  isPassword: true,
                ),
                CustomButton(
                  press: () async {
                    if (isFormValid()) {
                      Credentials credentials = Credentials(
                        username: userNameController.text,
                        password: passwordController.text,
                      );
                      String? serverErrorMessage =
                          await formService.connect(credentials);
                      if (serverErrorMessage == null) {
                        socketService.setup(SocketType.Auth, infoService.id);
                        chatService
                            .setGlobalChatListeners(); // TODO : move this (maybe)
                        Navigator.pushNamed(context, DASHBOARD_ROUTE);
                      } else {
                        setState(() {
                          errorMessage = serverErrorMessage;
                        });
                      }
                    } else {
                      setState(() {
                        errorMessage =
                            "Les entrées ne devraient pas être vides";
                      });
                    }
                  },
                  backgroundColor: kMidOrange,
                  textColor: kLight,
                  text: 'C O N N E X I O N',
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
                      Navigator.pushNamed(context, SIGN_UP_ROUTE);
                    },
                    child: Container(
                      child: Text(
                        "S' I N S C R I R E",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
