import 'package:mobile/models/models.dart';

class Profile {
  String avatar;
  List<SessionLog> sessions;
  List<ConnectionLog> connections;
  Statistics stats;
  List<Friend> friends;
  List<String> friendRequests;
  String? language;
  Theme? theme;
  Sound? soundOnDifference;
  Sound? soundOnError;

  Profile({
    required this.avatar,
    required this.sessions,
    required this.connections,
    required this.stats,
    required this.friends,
    this.friendRequests = const [],
    this.language,
    this.theme,
    this.soundOnDifference,
    this.soundOnError,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      avatar: json['avatar'],
      sessions: List<SessionLog>.from(
          json['sessions'].map((x) => SessionLog.fromJson(x))),
      connections: List<ConnectionLog>.from(
          json['connections'].map((x) => ConnectionLog.fromJson(x))),
      stats: Statistics.fromJson(json['stats']),
      friends:
          List<Friend>.from(json['friends'].map((x) => Friend.fromJson(x))),
      friendRequests: List<String>.from(json['friendRequests']),
      language: json['language'],
      theme: json['theme'] != null ? Theme.fromJson(json['theme']) : null,
      soundOnDifference: json['soundOnDifference'] != null
          ? Sound.fromJson(json['soundOnDifference'])
          : null,
      soundOnError: json['soundOnError'] != null
          ? Sound.fromJson(json['soundOnError'])
          : null,
    );
  }
}

class Credentials {
  final String username;
  final String password;
  final String? email;
  const Credentials(
      {required this.username, required this.password, this.email});

  static Credentials fromJson(Map<String, dynamic> json) {
    return Credentials(
      username: json['username'],
      password: json['password'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      if (email != null) 'email': email,
    };
  }
}

class SignUpCredentialsBody {
  Credentials credentials;
  String? id;
  SignUpCredentialsBody({
    required this.credentials,
    this.id = '1',
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["creds"] = credentials;
    data["id"] = id;
    return data;
  }
}

class UploadAvatarBody {
  String username;
  String? base64Avatar;
  String? id;
  UploadAvatarBody({
    required this.username,
    this.id,
    this.base64Avatar,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["username"] = username;
    data["avatar"] = base64Avatar;
    data["id"] = id;
    return data;
  }
}

class UploadPredefinedAvatarBody {
  String username;
  String id;
  UploadPredefinedAvatarBody({
    required this.username,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["username"] = username;
    data["id"] = id;
    return data;
  }
}

class Sound {
  final String name;
  final String? link;

  Sound({
    required this.name,
    this.link,
  });

  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      name: json['name'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (link != null) 'link': link,
    };
  }
}
