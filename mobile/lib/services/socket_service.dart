import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/chat_message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  static const String serverIP = '127.0.0.1';
  // static const String serverIP = '34.118.163.79';
  static const String serverPort = '3000';
  static const String serverURL = 'http://$serverIP:$serverPort';
  static final List<ChatMessage> messages = [];
  String approvedName = '';
  static IO.Socket authSocket = IO.io(serverURL, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  bool isConnectionApproved = true; // TODO : connect with connection page
  bool isSocketConnected = true; // TODO : connect with connection page

  String get userName => approvedName;
  List<ChatMessage> get allMessages => List.unmodifiable(messages);

  void setup() {
    authSocket = IO.io(serverURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': 'name=$userName'
    });

    authSocket.onConnect((_) {
      print('Connected to server on $serverIP:$serverPort');
      isSocketConnected = true;
      notifyListeners();
    });

    authSocket.onConnectError((data) => print('Connection error: $data'));
    authSocket.onDisconnect((_) {
      print('Disconnected from server');
      isSocketConnected = false;
      isConnectionApproved = false;

      notifyListeners();
    });

    //Event listeners
    authSocket.on(MessageEvents.GlobalMessage.name, (data) {
      print('GlobalMessage received: $data');
      ChatMessage message = ChatMessage.fromJson(data);
      print('Message: ${message.message}');
      print('Tag: ${message.tag}');
      print('User: ${message.userName}');
      print('Timestamp: ${message.timestamp}');
      addMessage(message);
      notifyListeners();
    });

    print('Socket setup complete');
  }

  void connect(SocketType type) {
    switch (type) {
      case SocketType.Auth:
        authSocket.connect();
        break;
      case SocketType.Lobby:
        break;
      case SocketType.Game:
        break;
    }
    // messages.clear(); // TODO : Figure out if we need this
  }

  void disconnect() {
    print('disconnecting from socket_service');
    approvedName = '';
    authSocket.disconnect();
  }

  void sendMessage(ChatMessage message) {
    print('Sending message');
    authSocket.emit(MessageEvents.GlobalMessage.name, message.toJson());
  }

  void addMessage(ChatMessage message) {
    print('Adding message${message.message}');
    messages.add(message);
    notifyListeners();
    print(allMessages.length);
  }

  void setName(String name) {
    print('Setting name : $name');
    approvedName = name;
  }
}
