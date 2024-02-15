import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/constants/app_constants.dart';

class ImageUploader extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  String? imageUrl;
  String? imagePath;

  List<String> imageFiles = [];

  void pickImage() async {
    XFile? _imageFile = await _picker.pickImage(source: ImageSource.camera);

    _imageFile = await cropImage(_imageFile!);
    if (_imageFile != null) {
      imageFiles.add(_imageFile.path);
      imagePath = _imageFile.path;
    } else {
      // TODO : Feedback
      return;
    }
  }

  Future<XFile?> cropImage(XFile imageFile) async {
    CroppedFile? croppedFile = await ImageCropper.platform.cropImage(
        sourcePath: imageFile.path,
        maxHeight: 800,
        maxWidth: 600,
        compressQuality: 70,
        cropStyle: CropStyle.rectangle,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio5x4
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Avatar cropper",
            toolbarColor: Color(kLightGreen.value),
            toolbarWidgetColor: Color(kLight.value),
            initAspectRatio: CropAspectRatioPreset.ratio5x4,
            lockAspectRatio: true,
          )
        ]);

    if (croppedFile != null) {
      notifyListeners();
      return XFile(croppedFile.path);
    } else {
      return null;
    }
  }
}
