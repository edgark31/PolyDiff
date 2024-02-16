import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/providers/login_provider.dart';
import 'package:mobile/views/common/customs/custom_app_bar.dart';
import 'package:mobile/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginNotifier>(builder: (context, loginNotifier, child) {
      loginNotifier.getPrefs();
      print(loginNotifier.entrypoint);
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: CustomAppBar(
            text: "C O N N E X I O N",
            child: loginNotifier.entrypoint && !loginNotifier.loggedIn
                ? GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(CupertinoIcons.arrow_left),
                  )
                : SizedBox.shrink(),
          ),
        ),
        body: Container(
          color: kLime,
          child: BottomNavBar(),
        ),
      );
    });
  }
}
