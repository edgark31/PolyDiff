import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../common/enums.dart';
import '../common/interfaces.dart';

class SocketService extends ChangeNotifier {
  // static const String serverIP = '127.0.0.1';
  static const String serverIP = '34.118.190.227';
  static const String serverPort = '3000';
  static const String serverURL = 'http://$serverIP:$serverPort';
  static IO.Socket socket = IO.io(serverURL, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  final List<ChatMessageGlobal> messages = [
    ChatMessageGlobal(
      MessageTag.Sent,
      'hello Zak',
      'Mark',
      '15:05:57',
    ),
    ChatMessageGlobal(
        MessageTag.Sent,
        'wanted to test out that writing a super long message wouldnt ruin the display of these text messages. Sorry for bothering you right now, even though I know your probably having fun at home with your raccoon friends you little raccoon',
        'Mark',
        '15:07:10'),
    ChatMessageGlobal(MessageTag.Received, 'good day mate', 'Zak', '15:48:10'),
    ChatMessageGlobal(
        MessageTag.Received,
        'No worries bro I was testing it out myself over here. Did you buy yo mamas christmas gift? She precisely said that she wanted something for her kitchen, something expensive',
        'Zak',
        '15:49:57'),
  ];

  bool isConnectionApproved = false;
  bool isSocketConnected = false;

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

    //event listeners
    socket.on(ConnectionEvents.UserConnectionRequest.name, (data) {
      print('UserConnectionRequest: $data');
      isConnectionApproved = data;
      if (!isConnectionApproved) {
        disconnect();
      }
      notifyListeners();
      // if (data) {
      //   connect();
      // }
    });

    socket.on(MessageEvents.GlobalMessage.name, (data) {
      print('GlobalMessage received: $data');
      ChatMessageGlobal message = ChatMessageGlobal.fromJson(data);
      print('Message: ${message.message}');
      print('Tag: ${message.tag}');
      print('User: ${message.userName}');
      print('Timestamp: ${message.timestamp}');
      // if (messages.contains(message)) {
      //   print('Message already exists');
      // } else {
      //   print('Adding message to list');
      addMessage(message);
      // }
      notifyListeners();
    });

    print('Socket setup complete');
  }

  void connect() {
    socket.connect();
    // messages.clear(); // TODO : Figure out if we need this
    // print('Socket connected');
    // isSocketConnected = true;
    // notifyListeners();
  }

  void disconnect() {
    socket.disconnect();
    // print('Socket disconnected');
    // isConnectionApproved = false;
    // isSocketConnected = false;
    // notifyListeners();
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
    // if (!messages.contains(message)) {
    messages.add(message);
    notifyListeners();
    print(allMessages.length);
    // }
  }

  void checkName(String name) {
    // IO.cache.clear();
    socket.dispose();
    setup();
    connect();

    print('Checking name : $name');
    socket.emit(ConnectionEvents.UserConnectionRequest.name, name);
  }
}
