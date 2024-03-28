import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';

class ChatService extends ChangeNotifier {
  static final List<Chat> _globalMessages = [];
  final SocketService socketService = Get.find();
  final LobbyService lobbyService = Get.find();

  List<Chat> get globalMessages => List.unmodifiable(_globalMessages);

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

  void sendGameMessage(String message) {
  socketService.send(
      SocketType.Game,
      ChannelEvents.SendGameMessage.name,
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

  void addGlobalChatList(List<Chat> messages) {
    _globalMessages.clear(); // safety check
    _globalMessages.addAll(messages);
    notifyListeners();
  }

  void setupGlobalChat() {
    setGlobalChatListeners();
    getGlobalMessages();
  }

  void getGlobalMessages() {
    socketService.send(SocketType.Auth, ChannelEvents.UpdateLog.name);
  }

  void setGlobalChatListeners() {
    socketService.on(SocketType.Auth, ChannelEvents.GlobalMessage.name, (data) {
      addGlobalMessage(Chat.fromJson(data as Map<String, dynamic>));
    });

    socketService.on(SocketType.Auth, ChannelEvents.UpdateLog.name, (data) {
      final ChatLog chatLog = ChatLog.fromJson(data as Map<String, dynamic>);
      addGlobalChatList(chatLog.chat);
    });
  }
}
