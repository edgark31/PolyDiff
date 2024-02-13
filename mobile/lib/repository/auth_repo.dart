import 'dart:ui';
import 'package:mobile/models/user_model.dart';

abstract class AuthRepo {
  Future<User?> registerNewUser(String email, String username, String password, Image avatar);

  Future<User?> signIn(String email, String username, String password);

  Future<bool> validate();
}