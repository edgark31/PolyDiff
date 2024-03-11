import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/socket_service.dart';

class ChatService extends ChangeNotifier {
  static final List<Chat> _globalMessages = [];
  final SocketService socketService = Get.find();

  List<Chat> get messages => List.unmodifiable(_globalMessages);

  void sendGlobalMessage(String message) {
    print('Sending message');
    socketService.send(
      SocketType.Auth,
      ChannelEvents.SendGlobalMessage.name,
      message,
    );
  }

  void addGlobalMessage(Chat message) {
    print('Adding global message saying ${message.raw} from ${message.name}');
    _globalMessages.add(message);
    notifyListeners();
    print('Length of global messages: ${_globalMessages.length}');
  }

  void setListeners() {
    socketService.on(SocketType.Auth, ChannelEvents.GlobalMessage.name, (data) {
      print('GlobalMessage received: $data');
      if (data is Map<String, dynamic>) {
        Chat message = Chat.fromJson(data);
        print('Message: ${message.raw}');
        print('Tag: ${message.tag}');
        print('User: ${message.name}');
        print('Timestamp: ${message.timestamp}');
        addGlobalMessage(message);
      } else {
        print('Received data is not a Map<String, dynamic>');
      }
    });
  }
}
