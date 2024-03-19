import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';

/// Represents a user's account.
class User {
  final String avatar;
  final List<SessionLog> sessions;
  final List<ConnectionLog> connections;
  final Statistics stats;
  final List<Friend> friends;
  final List<String> friendRequests;
  final String language;
  final String mobileTheme;
  final String onCorrectSoundId;
  final String onErrorSoundId;

  User({
    required this.avatar,
    required this.sessions,
    required this.connections,
    required this.stats,
    required this.friends,
    this.friendRequests = const [],
    this.language = 'fr',
    required this.mobileTheme,
    required this.onCorrectSoundId,
    required this.onErrorSoundId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
      mobileTheme: json['mobileTheme'],
      onCorrectSoundId: json['onCorrectSoundId'],
      onErrorSoundId: json['onErrorSoundId'],
    );
  }
}

class AccountSettings {
  final String username;
  final String id;
  final String avatar;
  final String email;
  final String theme;
  final String language;
  final String onErrorSound;
  final String onCorrectSound;

  AccountSettings({
    required this.username,
    required this.id,
    required this.avatar,
    required this.email,
    required this.theme,
    required this.language,
    required this.onErrorSound,
    required this.onCorrectSound,
  });

  factory AccountSettings.fromInfoService(InfoService service) {
    return AccountSettings(
      username: service.username,
      id: service.id,
      avatar: "",
      email: service.email,
      theme: service.theme,
      language: service.language,
      onErrorSound: service.onErrorSound,
      onCorrectSound: service.onCorrectSound,
    );
  }

  AccountSettings copyWith({
    String? username,
    String? id,
    String? avatar,
    String? email,
    String? theme,
    String? language,
    String? onErrorSound,
    String? onCorrectSound,
  }) {
    return AccountSettings(
      username: username ?? this.username,
      id: id ?? this.id,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      onErrorSound: onErrorSound ?? this.onErrorSound,
      onCorrectSound: onCorrectSound ?? this.onCorrectSound,
    );
  }

  // Helper method to detect if two settings are equal
  bool equals(AccountSettings other) {
    return username == other.username &&
        id == other.id &&
        avatar == other.avatar &&
        email == other.email &&
        theme == other.theme &&
        language == other.language &&
        onErrorSound == other.onErrorSound &&
        onCorrectSound == other.onCorrectSound;
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

/// Represents sound settings with specific IDs for correct and error sounds.
class Sound {
  final String onCorrectSoundId;
  final String onErrorSoundId;

  /// Constructs a [Sound] instance with IDs for correct and error sounds.
  /// If data is missing in JSON, defaults are provided to ensure the instance is in a valid state.
  Sound({
    required this.onCorrectSoundId,
    required this.onErrorSoundId,
  });

  /// Creates a [Sound] instance from a JSON map.
  /// Missing values are replaced with default IDs.
  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      onCorrectSoundId: json['onCorrectSoundId'] as String? ??
          DEFAULT_ON_CORRECT_SOUND_PATH_1,
      onErrorSoundId:
          json['onErrorSoundId'] as String? ?? DEFAULT_ON_ERROR_SOUND_PATH_1,
    );
  }

  /// Converts a [Sound] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'onCorrectSoundId': onCorrectSoundId,
      'onErrorSoundId': onErrorSoundId,
    };
  }
}
