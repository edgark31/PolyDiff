import 'package:flutter/material.dart';

class InfoService extends ChangeNotifier {
  static late String _name;
  static late String _id;
  static late String _avatar;
  static late String _email;

  String get name => _name;
  String get id => _id;
  String get avatar => _avatar;
  String get email => _email;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }
}
