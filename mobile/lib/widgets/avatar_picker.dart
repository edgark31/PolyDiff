import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/camera_image_provider.dart';
import 'package:mobile/services/avatar_service.dart';

typedef OnAvatarSelected = Function(ImageProvider image,
    {String? id, String? base64});

class AvatarPicker extends StatefulWidget {
  final OnAvatarSelected onAvatarSelected;

  const AvatarPicker({super.key, required this.onAvatarSelected});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  // Service to communicate with server
  final AvatarService _avatarService = AvatarService();
  // Providers
  final AvatarProvider _avatarProvider = AvatarProvider(baseUrl: API_URL);
  final CameraImageProvider _imageUploader = CameraImageProvider();

  ImageProvider? _selectedImage =
      AssetImage('assets/images/sleepyRaccoon.jpg'); // Placeholder image

  void _updateSelectedImage(ImageProvider image) {
    setState(() {
      _selectedImage = image;
    });
    widget.onAvatarSelected(image);
  }

  void _handlePredefinedAvatarSelection(String id) {
    ImageProvider image =
        NetworkImage(_avatarProvider.getDefaultAvatarUrl('1'));
    setState(() {
      _selectedImage = image;
    });
    widget.onAvatarSelected(image, id: id);
  }

  Future<void> _handleCameraImageSelection() async {
    final String? base64Image = await _imageUploader.pickImageFromCamera();
    if (base64Image != null) {
      Uint8List bytes = base64Decode(base64Image);
      ImageProvider image = MemoryImage(bytes);
      _updateSelectedImage(image);

      String? uploadError =
          await AvatarService().uploadCameraImage('username', bytes);
      if (uploadError == null) {
        print('success avatar service uploadCameraImage');
        _updateSelectedImage(image);
      } else {
        print("erreur lors de envoie au serveur $uploadError");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 120,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _handlePredefinedAvatarSelection('1');
                },
                child: avatarContainer(
                    NetworkImage(_avatarProvider.getDefaultAvatarUrl('1')),
                    kLightGreen),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => _handleCameraImageSelection(),
                child: SizedBox(
                  width: 100.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 50,
                    child:
                        Icon(Icons.camera_alt, size: 50, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget avatarContainer(ImageProvider image, Color backgroundColor) {
    return SizedBox(
      width: 100,
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: 50,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: image,
          radius: 48,
        ),
      ),
    );
  }
}
