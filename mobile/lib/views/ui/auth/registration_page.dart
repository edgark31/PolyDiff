import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/controllers/camera_image_provider.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
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
      body: Consumer<CameraImageUploader>(
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
    );
  }
}
