import 'package:mobile/models/models.dart';

class Profile {
  String avatar;
  List<SessionLog> sessions;
  List<ConnexionLog> connections;
  Statistics stats;
  List<Friend> friends;
  List<String> friendRequests;
  String? language;
  Theme? theme;

  Profile({
    required this.avatar,
    required this.sessions,
    required this.connections,
    required this.stats,
    required this.friends,
    this.friendRequests = const [],
    this.language,
    this.theme,
  });
}

class Credentials {
  final String username;
  final String password;
  final String? email;
  const Credentials(
      {required this.username, required this.password, this.email});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      if (email != null) 'email': email,
    };
  }
}
