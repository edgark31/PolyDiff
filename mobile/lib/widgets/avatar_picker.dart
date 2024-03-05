import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/constants/app_constants.dart';

class AvatarPicker extends StatefulWidget {
  final Function(ImageProvider) onAvatarSelected;

  const AvatarPicker({super.key, required this.onAvatarSelected});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  ImageProvider? _selectedImage = AssetImage('assets/images/sleepyRaccoon.jpg');

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
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => _updateSelectedImage(
                    AssetImage('assets/images/sleepyRaccoon.jpg')),
                child: avatarContainer(
                    AssetImage('assets/images/sleepyRaccoon.jpg'), kLightGreen),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => _updateSelectedImage(_selectedImage =
                    AssetImage('assets/images/hallelujaRaccoon.jpeg')),
                child: avatarContainer(
                    AssetImage('assets/images/hallelujaRaccoon.jpeg'),
                    kMidGreen),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => _updateSelectedImage(_selectedImage =
                    AssetImage('assets/images/cuteRaccoon.bmp')),
                child: avatarContainer(
                    AssetImage('assets/images/cuteRaccoon.bmp'), kLightOrange),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    _updateSelectedImage(FileImage(File(photo.path)));
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
          backgroundColor: backgroundColor,
          backgroundImage: image,
          radius: 40,
        ),
      ),
    );
  }
}
