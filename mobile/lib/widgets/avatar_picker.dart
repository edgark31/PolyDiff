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
  // Providers
  final CameraImageProvider _imageProvider = CameraImageProvider();

  void _handlePredefinedAvatarSelection(String id) {
    ImageProvider image = NetworkImage(getDefaultAvatarUrl(id));

    widget.onAvatarSelected(image, id: id);
  }

  Future<void> _handleCameraImageSelection() async {
    final String? base64Image = await _imageProvider.pickImageFromCamera();

    if (base64Image != null) {
      ImageProvider image = base64ToImage(base64Image);

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
              // First predefined avatar container
              GestureDetector(
                onTap: () {
                  _handlePredefinedAvatarSelection('1');
                },
                child: avatarContainer(
                    NetworkImage(getDefaultAvatarUrl('1')), kLightGreen),
              ),
              SizedBox(width: 20),
              // Second predefined avatar container
              GestureDetector(
                onTap: () {
                  _handlePredefinedAvatarSelection('2');
                },
                child: avatarContainer(
                    NetworkImage(getDefaultAvatarUrl('2')), kLightGreen),
              ),
              SizedBox(width: 20),
              // TODO: Third predefined avatar container
              // Tablet camera image container
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
