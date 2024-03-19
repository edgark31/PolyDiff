import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';

// Singleton
class AvatarProvider extends ChangeNotifier {
  static final AvatarProvider _instance = AvatarProvider._internal();
  factory AvatarProvider() => _instance;
  AvatarProvider._internal();

  static AvatarProvider get instance => _instance;

  String _currentAvatarUrl = '';
  String get currentAvatarUrl => _currentAvatarUrl;

  void setAccountAvatarUrl(String id) {
    // Append a timestamp to the URL as a cache-buster
    final String newAvatarUrl = '$BASE_URL/avatar/$id.png';
    print('Changing avatar from $_currentAvatarUrl to $newAvatarUrl');
    imageCache.evict(AvatarProvider.instance.currentAvatarUrl);
    _instance._currentAvatarUrl = newAvatarUrl;
    _instance.notifyListeners();
  }

  static void setInitialAvatar() {
    const String defaultId = '1';
    // Include the cache-buster here too if the initial avatar might change and need refreshing
    final String newAvatarUrl =
        '$BASE_URL/avatar/default$defaultId.png?timestamp=${DateTime.now().millisecondsSinceEpoch}';
    _instance._currentAvatarUrl = newAvatarUrl;
    _instance.notifyListeners();
  }
}
