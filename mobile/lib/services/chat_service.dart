import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/services/socket_service.dart';

class ChatService extends ChangeNotifier {
  static final List<Chat> _globalMessages = [];
  static final List<Chat> _lobbyMessages = [];
  final SocketService socketService = Get.find();
  final LobbyService lobbyService = Get.find();
  final InfoService infoService = Get.find();

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

  void addLobbyMessage(Chat message) {
    _lobbyMessages.add(message);
    notifyListeners();
  }

  void setupGlobalChat() {
    setGlobalChatListeners();
    getGlobalMessages();
  }

  void setupLobby() {
    setLobbyChatListeners();
  }

  void setupGame() {
    setGameChatListeners();
  }

  void setLobbyMessages(List<Chat> messages) {
    _lobbyMessages.clear(); // safety check
    _lobbyMessages.addAll(messages);
    print('addAll - _lobbyMessages:');
    print(_lobbyMessages);
    notifyListeners();
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

  void setLobbyChatListeners() {
    socketService.on(SocketType.Lobby, ChannelEvents.LobbyMessage.name, (data) {
      addLobbyMessage(Chat.fromJson(data as Map<String, dynamic>));
    });
  }

  void setGameChatListeners() {
    socketService.on(SocketType.Game, ChannelEvents.GameMessage.name, (data) {
      Chat gameMessageReceived = Chat.fromJson(data as Map<String, dynamic>);
      if (infoService.language == 'en') {
        const String differenceFoundFR = 'a trouvé une différence !';
        const String mistakeFR = "s'est trompé !";
        const String abandonFR = "a abandonné la partie !";
        if (gameMessageReceived.raw.endsWith(differenceFoundFR)) {
          gameMessageReceived.raw = gameMessageReceived.raw
              .replaceFirst(differenceFoundFR, 'found a difference!');
        } else if (gameMessageReceived.raw.endsWith(mistakeFR)) {
          gameMessageReceived.raw = gameMessageReceived.raw
              .replaceFirst(mistakeFR, "made a mistake!");
        } else if (gameMessageReceived.raw.endsWith(abandonFR)) {
          gameMessageReceived.raw = gameMessageReceived.raw
              .replaceFirst(abandonFR, "gave up !");
        }
      }
      addLobbyMessage(gameMessageReceived);
    });
  }
}
