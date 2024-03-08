import 'package:mobile/constants/app_routes.dart';

class AvatarProvider {
  final String baseUrl;

  AvatarProvider({this.baseUrl = BASE_URL});

  String getDefaultAvatarUrl(String id) {
    print('$AVATAR_URL/default$id.png');
    return '$AVATAR_URL/default$id.png';
  }

  String getAccountAvatar(String username) {
    return '$AVATAR_URL/$username.png';
  }
}
