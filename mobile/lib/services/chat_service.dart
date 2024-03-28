import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';

class ChatService extends ChangeNotifier {
  static final List<Chat> _globalMessages = [];
  static List<Chat> _lobbyMessages = []; // Remove when ChatLog set up
  final SocketService socketService = Get.find();
  final LobbyService lobbyService = Get.find();

  List<Chat> get globalMessages => List.unmodifiable(_globalMessages);
  List<Chat> get lobbyMessages => List.unmodifiable(_lobbyMessages);  // Remove when ChatLog set up

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


  void addLobbyMessage(Chat message) { // Remove when ChatLog set up
    _lobbyMessages.add(message);
    notifyListeners();
  }


  void setupGlobalChat() {
    setGlobalChatListeners();
    getGlobalMessages();
  }

  void setupLobby () { // Remove when ChatLog set up
    clearLobbyMessages();
    setLobbyChatListeners();
  }

  void setupGame() { // Remove when ChatLog set up
    clearLobbyMessages();
    setGameChatListeners();
  }

  void setLobbyMessages(List<Chat> messages) { // Remove when ChatLog set up
    _lobbyMessages.clear();
    _lobbyMessages.addAll(messages);
    notifyListeners();
  }

  void clearLobbyMessages() { // Remove when ChatLog set up
    _lobbyMessages.clear();
    notifyListeners();
  }

  // void setupLobby() {  // Remove when ChatLog set up
  //   _lobbyMessages.clear(); // safety check
  //   if (lobbyService.lobby.chatLog != null) {
  //     _lobbyMessages = lobbyService.lobby.chatLog!.chat;
  //   } else {
  //     _lobbyMessages = [];
  //   }
    
  // }

  // void setupGame() { // Remove when ChatLog set up
  //   setGameChatListeners();
  // }

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

    void setLobbyChatListeners() { // Remove when ChatLog set up
    socketService.on(SocketType.Lobby, ChannelEvents.LobbyMessage.name, (data) {
      addLobbyMessage(Chat.fromJson(data as Map<String, dynamic>));
    });
  }

  void setGameChatListeners() { // Remove when ChatLog set up
    socketService.on(SocketType.Game, ChannelEvents.GameMessage.name, (data) {
      addLobbyMessage(Chat.fromJson(data as Map<String, dynamic>));
    });
  }

}
