import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/pages/registration_page.dart';
import 'package:mobile/views/common/customs/app_style.dart';
import 'package:mobile/views/common/customs/custom_btn.dart';
import 'package:mobile/views/common/customs/height_spacer.dart';
import 'package:mobile/views/common/customs/reusable_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double startingPoint = screenHeight * 0.5;

    return Scaffold(
      body: Container(
        color: Color(kLightGreen.value),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/MenuBackground.jpg",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: startingPoint),
                    child: Column(
                      children: [
                        ReusableText(
                          text: "PolyDiff",
                          style: appstyle(
                              30, Color(kLightOrange.value), FontWeight.w600),
                        ),
                        HeightSpacer(size: 70),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              onTap: () async {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('entrypoint', true);
                                Get.to(() => const LoginPage());
                              },
                              text: "Connexion",
                              width: scaler.getWidth(20),
                              height: scaler.getHeight(10),
                              color: Color(kLight.value),
                              color2: Color(kMidGreen.value),
                            ),
                            Flexible(
                              child: SizedBox(width: scaler.getWidth(5)),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => RegistrationPage());
                              },
                              child: CustomButton(
                                text: "Inscription",
                                width: scaler.getWidth(20),
                                height: scaler.getHeight(10),
                                color: Color(kMidGreen.value),
                                color2: Color(kLight.value),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ReusableText(
                            text: "@ RACCOON VILLAGE ",
                            style: appstyle(
                              3,
                              Color(kDarkGreen.value),
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
