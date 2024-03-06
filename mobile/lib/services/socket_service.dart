import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/chat_message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  // TODO: fix singleton issue
  static final SocketService _singleton = SocketService._internal();

  factory SocketService() {
    return _singleton;
  }

  SocketService._internal();
  static const String serverIP = '127.0.0.1';
  // static const String serverIP = '34.118.163.79';
  static const String serverPort = '3000';
  static const String serverURL = 'http://$serverIP:$serverPort';
  static final List<ChatMessage> messages = [];
  // String approvedName = '';
  // String inputName = '';
  String approvedName = 'admin'; // TODO: change to user input
  String inputName = 'admin'; // TODO: change to user input
  static IO.Socket authSocket = IO.io(serverURL, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
    'query': 'name=admin' // TODO: change to user input
  });

  // bool isConnectionApproved = false;
  // bool isSocketConnected = false;
  bool isConnectionApproved = true; // TODO : connect with connection page
  bool isSocketConnected = true; // TODO : connect with connection page

  String get userName => approvedName;
  bool get connectionStatus => isConnectionApproved;
  bool get socketStatus => isSocketConnected;
  List<ChatMessage> get allMessages => List.unmodifiable(messages);

  void setup() {
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
    authSocket.on(ConnectionEvents.UserConnectionRequest.name, (data) {
      print('UserConnectionRequest: $data');
      isConnectionApproved = data;
      if (!isConnectionApproved) {
        disconnect();
      } else if (inputName != '') {
        approvedName = inputName;
      }
      connectionStatus
          ? print('Connection approved')
          : print('Connection denied');
      notifyListeners();
    });

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
    messages.clear(); // TODO : Figure out if we need this
  }

  void disconnect() {
    print('disconnecting from socket_service');
    approvedName = '';
    inputName = '';
    authSocket.disconnect();
  }

  void sendTestMessage() {
    print('Sending test message');
    final ChatMessage testMessage = ChatMessage(
      MessageTag.Sent,
      'test message',
      'Zooboomafoo',
      'test',
    );
    authSocket.emit(MessageEvents.GlobalMessage.name, testMessage.toJson());
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

  void checkName(String name) {
    authSocket.dispose();
    setup();
    connect(SocketType.Auth);

    print('Checking name : $name');
    authSocket.emit(ConnectionEvents.UserConnectionRequest.name, name);
    inputName = name;
  }
}
