import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/services.dart';
import 'package:mobile/widgets/customs/app_style.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:mobile/widgets/customs/custom_text_input_field.dart';
import 'package:provider/provider.dart';

class ConnectionForm extends StatefulWidget {
  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
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
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).size.height * 0.3;
    final socketService = context.watch<SocketService>();
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
                  press: () {
                    // TODO: Handle connection logic here
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
                      Navigator.pushNamed(context, SIGNUP_ROUTE);
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
