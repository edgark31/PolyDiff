import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/info_service.dart';

// Singleton
class AvatarProvider extends ChangeNotifier {
  final InfoService _infoService = Get.find();

  String _currentAvatarUrl = '';
  String get currentAvatarUrl => _currentAvatarUrl;

  void setAccountAvatarUrl() {
    imageCache.clear();
    imageCache.clearLiveImages();
    imageCache.evict(currentAvatarUrl);

    final String userId = _infoService.id;
    // Append a timestamp to the URL as a cache-buster
    final String newAvatarUrl = '$BASE_URL/avatar/$userId.png';
    _currentAvatarUrl = "";
    print('Changing avatar from $_currentAvatarUrl to $newAvatarUrl');
    _currentAvatarUrl = newAvatarUrl;
    notifyListeners();
  }
}
