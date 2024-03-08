import 'package:mobile/constants/app_routes.dart';

class AvatarProvider {
  final String baseUrl;

  AvatarProvider({this.baseUrl = API_URL});

  String getDefaultAvatarUrl(String id) {
    // TODO : remove when completed
    print('$BASE_URL/default$id.png');
    return '$BASE_URL/default$id.png';
  }

  String getAccountAvatar(String username) {
    return '$BASE_URL/$username.png';
  }
}
