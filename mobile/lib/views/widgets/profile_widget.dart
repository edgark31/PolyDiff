import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/controllers/profile_controller.dart';
import 'package:mobile/models/models.dart';

class AccountView extends StatefulWidget {
  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  Profile? _profile;

  final ProfileController _controller = ProfileController();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _onCameraButtonPressed() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _controller.updateProfileAvatar(_profile!, File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(_profile!.avatar),
          ),
          SizedBox(height: 20),
          Text(_profile!.username),
          ElevatedButton(
            onPressed: _onCameraButtonPressed,
            child: Text('Take a Photo'),
          ),
        ],
      ),
    );
  }
}
