import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/controllers/camera_image_provider.dart';
import 'package:mobile/controllers/login_provider.dart';
import 'package:mobile/views/common/drawer/app_style.dart';
import 'package:mobile/views/common/drawer/custom_btn.dart';
import 'package:mobile/views/common/drawer/reusable_text.dart';
import 'package:provider/provider.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  // TODO : add avatar picture
  File? imageFile;

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void setImage(File? image) {
    setState(() {
      imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginNotifier>(
        builder: (context, loginNotifier, child) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableText(
                    text: "Profile",
                    style: appstyle(35, Color(kDark.value), FontWeight.bold),
                  ),
                  Consumer<CameraImageUploader>(
                    builder: (context, cameraImageUploader, child) {
                      return Column(
                        children: [
                          MaterialButton(
                            color: Colors.blue,
                            child: const Text(
                              "Pick Image from Camera",
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              cameraImageUploader.pickImageFromCamera(setImage);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          cameraImageUploader.image != null
                              ? Image.file(cameraImageUploader.image!)
                              : Text("No image selected"),
                        ],
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              CustomButton(
                onTap: () {
                  // Handle the update action here
                },
                text: 'Mettre à jour',
              ),
              // TODO: Add CustomTextField
            ],
          );
        },
      ),
    );
  }
}
