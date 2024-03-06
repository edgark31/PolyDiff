import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/providers/camera_image_provider.dart';

class AvatarPicker extends StatefulWidget {
  final Function(ImageProvider) onAvatarSelected;

  const AvatarPicker({Key? key, required this.onAvatarSelected})
      : super(key: key);

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final AvatarProvider _avatarProvider = AvatarProvider(baseUrl: BASE_URL);
  final CameraImageUploader _imageUploader = CameraImageUploader();
  ImageProvider? _selectedImage =
      AssetImage('assets/images/sleepyRaccoon.jpg'); // Placeholder image

  void _updateSelectedImage(ImageProvider image) {
    setState(() {
      _selectedImage = image;
    });
    widget.onAvatarSelected(image);
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
              for (int id = 1; id <= 3; id++)
                GestureDetector(
                  onTap: () => _updateSelectedImage(
                      NetworkImage(_avatarProvider.getDefaultAvatarUrl('$id'))),
                  child: avatarContainer(
                      NetworkImage(_avatarProvider.getDefaultAvatarUrl('$id')),
                      kLightGreen),
                ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  final String? base64Image =
                      await _imageUploader.pickImageFromCamera();
                  if (base64Image != null) {
                    Uint8List bytes = base64Decode(base64Image);
                    _updateSelectedImage(MemoryImage(bytes));
                  }
                },
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
