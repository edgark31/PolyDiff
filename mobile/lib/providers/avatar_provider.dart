import 'package:mobile/constants/app_routes.dart';

class AvatarProvider {
  final String baseUrl;

  AvatarProvider({this.baseUrl = API_URL});

  String getDefaultAvatarUrl(String id) {
    print('$BASE_URL/avatar/default$id.png');
    return '$BASE_URL/avatar/default$id.png';
  }

  String getAccountAvatar(String username) {
    return '$BASE_URL/avatar/$username.png';
  }
}
