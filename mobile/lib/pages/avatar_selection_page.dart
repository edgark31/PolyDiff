import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';

class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({super.key, required this.title});

  static const routeName = AVATAR_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => AvatarSelectionPage(title: 'avatar'),
      settings: RouteSettings(name: routeName),
    );
  }

  final String title;

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  // Default raccoon avatar
  ImageProvider? _selectedImage = AssetImage('assets/images/sleepyRaccoon.jpg');

  Future<void> _pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    // Capture a photo
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        // Update the _selectedImage with the new photo
        _selectedImage = FileImage(File(photo.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 20.0),
          height: 200.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              SizedBox(width: 10),
              Container(
                width: 200.0,
                child: buildMinMaxAvatar(),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedImage = AssetImage('assets/images/shookRaccoon.bmp');
                }),
                child: avatarContainer(
                    AssetImage('assets/images/shookRaccoon.bmp'), kLightGreen),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedImage =
                      AssetImage('assets/images/hallelujaRaccoon.jpeg');
                }),
                child: avatarContainer(
                    AssetImage('assets/images/hallelujaRaccoon.jpeg'),
                    kMidGreen),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedImage = AssetImage('assets/images/cuteRaccoon.bmp');
                }),
                child: avatarContainer(
                    AssetImage('assets/images/cuteRaccoon.bmp'), kLightOrange),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: _pickImageFromCamera,
                child: Container(
                  width: 160.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 80,
                    child: Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildMinMaxAvatar() {
    const double size = 100;
    return Container(
      width: size,
      height: size,
      child: Center(
        child: CircleAvatar(
          backgroundColor: Colors.orange,
          backgroundImage: _selectedImage, // selected image updates here
          minRadius: 12,
          maxRadius: 36,
        ),
      ),
    );
  }

  Widget avatarContainer(ImageProvider image, Color backgroundColor) {
    return Container(
      width: 160.0,
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: 80,
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          backgroundImage: image,
          radius: 65,
        ),
      ),
    );
  }
}
