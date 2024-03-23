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
    socketService.send(
      SocketType.Auth,
      ChannelEvents.SendGlobalMessage.name,
      message,
    );
  }

  void sendLobbyMessage(String message) {
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
    _globalMessages.add(message);
    notifyListeners();
  }

  void addLobbyMessage(Chat message) {
    _lobbyMessages.add(message);
    notifyListeners();
  }

  void setupLobby() {
    clearLobbyMessages();
    setLobbyChatListeners();
  }

  void setupGame() {
    clearLobbyMessages();
    setGameChatListeners();
  }

  void setLobbyMessages(List<Chat> messages) {
    _lobbyMessages.clear();
    _lobbyMessages.addAll(messages);
    notifyListeners();
  }

  void clearLobbyMessages() {
    _lobbyMessages.clear();
    notifyListeners();
  }

  void setGlobalChatListeners() {
    socketService.on(SocketType.Auth, ChannelEvents.GlobalMessage.name, (data) {
      addGlobalMessage(Chat.fromJson(data as Map<String, dynamic>));
    });
  }

  void setLobbyChatListeners() {
    socketService.on(SocketType.Lobby, ChannelEvents.LobbyMessage.name, (data) {
      addLobbyMessage(Chat.fromJson(data as Map<String, dynamic>));
    });
  }

  void setGameChatListeners() {
    socketService.on(SocketType.Game, ChannelEvents.GameMessage.name, (data) {
      addLobbyMessage(Chat.fromJson(data as Map<String, dynamic>));
    });
  }
}
