import 'package:mobile/constants/app_routes.dart';

class AvatarProvider {
  final String baseUrl;

  AvatarProvider({this.baseUrl = BASE_URL});

  String getDefaultAvatarUrl(String id) {
    return '$baseUrl/avatar/default$id.png';
  }
}
