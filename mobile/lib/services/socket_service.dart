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
  static late IO.Socket authSocket;
  static late IO.Socket lobbySocket;
  static late IO.Socket gameSocket;

  String get userName => approvedName;
  List<ChatMessage> get allMessages => List.unmodifiable(messages);

  void setup(SocketType type) {
    print('setup ${type.name} started');
    switch (type) {
      case SocketType.Auth:
        authSocket = IO.io(serverURL, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': 'name=$approvedName'
        });
        setSocket(authSocket);
        // setupEventListenersAuthSocket();
        break;
      case SocketType.Lobby:
        lobbySocket = IO.io("$serverURL/lobby", <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': 'name=$approvedName'
        });
        setSocket(lobbySocket);
        break;
      case SocketType.Game:
        gameSocket = IO.io("$serverURL/game", <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': 'name=$approvedName'
        });
        setSocket(gameSocket);
        break;
    }
    print("Setup ${type.name} completed");
  }

  void setSocket(IO.Socket socket) {
    print('Initializing socket');

    print('Calling onConnect socket');
    socket.onConnect((_) {
      print('Connected to server on $serverIP:$serverPort');
    });

    print('Calling onConnectError socket');
    socket.onConnectError((data) => print('Connection error: $data'));

    print('Calling onDisconnect socket');
    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void setupEventListenersAuthSocket() {
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
  }

  void connect(SocketType type) {
    print("Connecting socket ${type.name}");
    setup(type);
    switch (type) {
      case SocketType.Auth:
        authSocket.connect();
        break;
      case SocketType.Lobby:
        lobbySocket.connect();
        break;
      case SocketType.Game:
        gameSocket.connect();
        break;
    }
  }

  void disconnect(SocketType type) {
    switch (type) {
      case SocketType.Auth:
        authSocket.disconnect();
        break;
      case SocketType.Lobby:
        break;
      case SocketType.Game:
        break;
    }
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
