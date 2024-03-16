import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/services/socket_service.dart';

class GameManagerService extends ChangeNotifier {
  final SocketService socketService = Get.find();
}
