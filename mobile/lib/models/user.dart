import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final String status;
  final String language;
  final String theme;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.status,
    required this.language,
    required this.theme,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? status,
    String? language,
    String? theme,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? const Uuid().v4(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl:
          json['avatar_url'] ?? 'https://source.unsplash.com/random/?profile',
      status: json['status'] ?? '',
      language: json['language'] ?? 'fr',
      theme: json['theme'] ?? 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'status': status,
      'language': language,
      'theme': theme,
    };
  }

  @override
  List<Object?> get props => [id, username, email, avatarUrl, status, language, theme];
}
