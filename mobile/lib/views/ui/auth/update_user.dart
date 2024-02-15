import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/controllers/image_provider.dart';
import 'package:mobile/controllers/login_provider.dart';
import 'package:mobile/views/common/drawer/app_style.dart';
import 'package:mobile/views/common/drawer/custom_btn.dart';
import 'package:mobile/views/common/drawer/height_spacer.dart';
import 'package:mobile/views/common/drawer/reusable_text.dart';
import 'package:provider/provider.dart';

class ProfileConfigurationPage extends StatefulWidget {
  const ProfileConfigurationPage({super.key});

  @override
  State<ProfileConfigurationPage> createState() =>
      _ProfileConfigurationPageState();
}

class _ProfileConfigurationPageState extends State<ProfileConfigurationPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  // TODO : add avatar picture

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<LoginNotifier>(builder: (context, loginNotifier, child) {
      return ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ReusableText(
                    text: "Profile",
                    style: appstyle(35, Color(kDark.value), FontWeight.bold)),
                Consumer<ImageUploader>(
                    builder: (context, imageUploader, child) {
                  return GestureDetector(
                    onTap: () {
                      imageUploader.pickImage();
                    },
                    child: CircleAvatar(
                      backgroundColor: Color(kLightGreen.value),
                      child: const Center(
                        child: Icon(Icons.photo_filter_rounded),
                      ),
                    ),
                  );
                })
              ],
            ),
            HeightSpacer(size: 20),

            CustomButton(onTap: () {}, text: 'Mettre à jour'),

            // TODO : add CustomTextField
          ]);
    }));
  }
}
