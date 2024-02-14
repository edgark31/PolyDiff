import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/views/common/drawer/app_style.dart';
import 'package:mobile/views/common/drawer/custom_outline_btn.dart';
import 'package:mobile/views/common/drawer/height_spacer.dart';
import 'package:mobile/views/common/drawer/reusable_text.dart';
import 'package:mobile/views/ui/auth/login.dart';
import 'package:mobile/views/ui/auth/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    return Scaffold(
        body: Container(
            width: width,
            height: height,
            color: Color(kLightGreen.value),
            child: Column(
              children: [
                Image.asset("assets/images/MenuBackground.jpg"),
                const HeightSpacer(size: 20),
                ReusableText(
                    text: "PolyDiff",
                    style: appstyle(30, Color(kLight.value), FontWeight.w600)),
                const HeightSpacer(size: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Où la différence est la clé du succès !",
                    textAlign: TextAlign.center,
                    style: appstyle(14, Color(kLight.value), FontWeight.normal),
                  ),
                ),
                HeightSpacer(size: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomOutlineBtn(
                      onTap: () async {
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('entrypoint', true);
                        Get.to(() => const LoginPage());
                      },
                      text: "Connexion",
                      width: width * 0.4,
                      height: height * 0.06,
                      color1: Color(kLight.value),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => RegistrationPage());
                      },
                      child: Container(
                        width: width * 0.4,
                        height: height * 0.06,
                        child: ReusableText(
                          text: "Inscription",
                          style: appstyle(
                              16, Color(kLight.value), FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )));
  }
}
