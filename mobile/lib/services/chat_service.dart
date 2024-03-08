import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/socket_service.dart';

class ChatService extends ChangeNotifier {
  static final List<ChatMessage> _messages = [];
  final SocketService socketService = Get.find();

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendMessage(ChatMessage message) {
    print('Sending message');
    socketService.send(
        SocketType.Auth, MessageEvents.GlobalMessage.name, message.toJson());
  }

  void addMessage(ChatMessage message) {
    print('Adding message${message.message}');
    _messages.add(message);
    notifyListeners();
    print('Length of messages: ${_messages.length}');
  }

  void setListeners() {
    socketService.on(SocketType.Auth, MessageEvents.GlobalMessage.name, (data) {
      print('GlobalMessage received: $data');
      if (data is Map<String, dynamic>) {
        ChatMessage message = ChatMessage.fromJson(data);
        print('Message: ${message.message}');
        print('Tag: ${message.tag}');
        print('User: ${message.userName}');
        print('Timestamp: ${message.timestamp}');
        addMessage(message);
      } else {
        print('Received data is not a Map<String, dynamic>');
      }
    });
  }
}
