import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';

// Singleton
class AvatarProvider with ChangeNotifier {
  static final AvatarProvider _instance = AvatarProvider._internal();
  factory AvatarProvider() => _instance;
  AvatarProvider._internal();

  static AvatarProvider get instance => _instance;

  String _currentAvatarUrl = '';
  String get currentAvatarUrl => _currentAvatarUrl;

  void setAccountAvatarUrl(String username) {
    _currentAvatarUrl = '$BASE_URL/avatar/$username.png';
    notifyListeners();
  }

  static void setInitialAvatar() {
    const String defaultId = '1';
    _instance._currentAvatarUrl = '$BASE_URL/avatar/default$defaultId.png';
    _instance.notifyListeners();
  }
}
