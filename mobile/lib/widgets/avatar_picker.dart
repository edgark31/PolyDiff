import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
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
  final CameraImageProvider _imageProvider = CameraImageProvider();

  ImageProvider? _selectedImage =
      AssetImage('assets/images/sleepyRaccoon.jpg'); // Placeholder image

  // selected avatar displayed but not uploaded
  void _updateSelectedImage(ImageProvider image) {
    setState(() {
      _selectedImage = image;
    });
    widget.onAvatarSelected(image);
  }

  void _handlePredefinedAvatarSelection(String id) {
    ImageProvider image = NetworkImage(_avatarService.getDefaultAvatarUrl(id));
    setState(() {
      _selectedImage = image;
    });
    widget.onAvatarSelected(image, id: id);
  }

  Future<void> _handleCameraImageSelection() async {
    final String? base64Image = await _imageProvider.pickImageFromCamera();

    if (base64Image != null) {
      ImageProvider image = _avatarService.base64ToImage(base64Image);
      setState(() {
        _selectedImage = image;
      });

      widget.onAvatarSelected(image, base64: base64Image);
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
                    NetworkImage(_avatarService.getDefaultAvatarUrl('1')),
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

  // TODO: remplace with reusable component
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
