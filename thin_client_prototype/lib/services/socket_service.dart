import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../common/enums.dart';
import '../common/interfaces.dart';

class SocketService extends ChangeNotifier {
  static const String serverIP = '34.118.163.79';
  static const String serverPort = '3000';
  static const String serverURL = 'http://$serverIP:$serverPort';
  static IO.Socket socket = IO.io(serverURL, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  final List<ChatMessageGlobal> messages = [];
  String approvedName = '';
  String inputName = '';

  bool isConnectionApproved = false;
  bool isSocketConnected = false;

  String get userName => approvedName;
  bool get connectionStatus => isConnectionApproved;
  bool get socketStatus => isSocketConnected;
  List<ChatMessageGlobal> get allMessages => List.unmodifiable(messages);

  void setup() {
    socket.onConnect((_) {
      print('Connected to server on $serverIP:$serverPort');
      isSocketConnected = true;
      notifyListeners();
    });
    socket.onConnectError((data) => print('Connection error: $data'));
    socket.onDisconnect((_) {
      print('Disconnected from server');
      isSocketConnected = false;
      isConnectionApproved = false;

      notifyListeners();
    });

    //Event listeners
    socket.on(ConnectionEvents.UserConnectionRequest.name, (data) {
      print('UserConnectionRequest: $data');
      isConnectionApproved = data;
      if (!isConnectionApproved) {
        disconnect();
      } else if (inputName != '') {
        approvedName = inputName;
      }
      notifyListeners();
    });

    socket.on(MessageEvents.GlobalMessage.name, (data) {
      print('GlobalMessage received: $data');
      ChatMessageGlobal message = ChatMessageGlobal.fromJson(data);
      print('Message: ${message.message}');
      print('Tag: ${message.tag}');
      print('User: ${message.userName}');
      print('Timestamp: ${message.timestamp}');
      addMessage(message);
      notifyListeners();
    });

    print('Socket setup complete');
  }

  void connect() {
    socket.connect();
    messages.clear(); // TODO : Figure out if we need this
  }

  void disconnect() {
    approvedName = '';
    inputName = '';
    socket.disconnect();
  }

  void sendTestMessage() {
    print('Sending test message');
    final ChatMessageGlobal testMessage = ChatMessageGlobal(
      MessageTag.Sent,
      'test message',
      'Zooboomafoo',
      'test',
    );
    socket.emit(MessageEvents.GlobalMessage.name, testMessage.toJson());
  }

  void sendMessage(ChatMessageGlobal message) {
    print('Sending message');
    socket.emit(MessageEvents.GlobalMessage.name, message.toJson());
  }

  void addMessage(ChatMessageGlobal message) {
    messages.add(message);
    notifyListeners();
    print(allMessages.length);
  }

  void checkName(String name) {
    socket.dispose();
    setup();
    connect();

    print('Checking name : $name');
    socket.emit(ConnectionEvents.UserConnectionRequest.name, name);
    inputName = name;
  }
}
