import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';

class ChatService extends ChangeNotifier {
  static final List<Chat> _globalMessages = [];
  static final List<Chat> _lobbyMessages = [];
  final SocketService socketService = Get.find();
  final LobbyService lobbyService = Get.find();

  List<Chat> get globalMessages => List.unmodifiable(_globalMessages);
  List<Chat> get lobbyMessages => List.unmodifiable(_lobbyMessages);

  void sendGlobalMessage(String message) {
    print('Sending message');
    socketService.send(
      SocketType.Auth,
      ChannelEvents.SendGlobalMessage.name,
      message,
    );
  }

  void sendLobbyMessage(String message) {
    print('Sending message');
    socketService.send(
      SocketType.Lobby,
      ChannelEvents.SendLobbyMessage.name,
      {
        'lobbyId': lobbyService.lobby.lobbyId,
        'message': message,
      },
    );
  }

  void addGlobalMessage(Chat message) {
    print('Adding global message saying ${message.raw} from ${message.name}');
    _globalMessages.add(message);
    notifyListeners();
    print('Length of global messages: ${_globalMessages.length}');
  }

  void addLobbyMessage(Chat message) {
    print('Adding lobby message saying ${message.raw} from ${message.name}');
    _lobbyMessages.add(message);
    notifyListeners();
    print('Length of lobby messages: ${_lobbyMessages.length}');
  }

  void clearLobbyMessages() {
    _lobbyMessages.clear();
    notifyListeners();
  }

  void setGlobalChatListeners() {
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

  void setLobbyChatListeners() {
    socketService.on(SocketType.Lobby, ChannelEvents.LobbyMessage.name, (data) {
      print('LobbyMessage received: $data');
      if (data is Map<String, dynamic>) {
        Chat message = Chat.fromJson(data);
        print('Message: ${message.raw}');
        print('Tag: ${message.tag}');
        print('User: ${message.name}');
        print('Timestamp: ${message.timestamp}');
        addLobbyMessage(message);
      } else {
        print('Received data is not a Map<String, dynamic>');
      }
    });
  }
}
