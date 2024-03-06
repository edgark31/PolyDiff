import 'package:flutter/material.dart';
import 'package:mobile/constants/enums.dart';
import 'package:mobile/models/chat_message_model.dart';
import 'package:mobile/pages/game_page.dart';
import 'package:mobile/providers/room_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  static const String serverIP = '34.118.163.79';
  static const String serverPort = '3000';
  static const String serverURL = 'http://$serverIP:$serverPort';
  static IO.Socket socket = IO.io(serverURL, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  final List<ChatMessage> messages = [];
  String approvedName = '';
  String inputName = '';

  bool isConnectionApproved = false;
  bool isSocketConnected = false;

  String get userName => approvedName;
  bool get connectionStatus => isConnectionApproved;
  bool get socketStatus => isSocketConnected;
  List<ChatMessage> get allMessages => List.unmodifiable(messages);

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
      connectionStatus
          ? print('Connection approved')
          : print('Connection denied');
      notifyListeners();
    });

    socket.on(MessageEvents.GlobalMessage.name, (data) {
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
    final ChatMessage testMessage = ChatMessage(
      MessageTag.Sent,
      'test message',
      'Zooboomafoo',
      'test',
    );
    socket.emit(MessageEvents.GlobalMessage.name, testMessage.toJson());
  }

  void sendMessage(ChatMessage message) {
    print('Sending message');
    socket.emit(MessageEvents.GlobalMessage.name, message.toJson());
  }

  void addMessage(ChatMessage message) {
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

  // GAME EMITS
  void createRoom(String gameId) {
    socket.emit('createClassicRoom', {'gameId': gameId});
  }

  void joinRoom(String username, String roomId) {
    if (username.isNotEmpty && roomId.isNotEmpty) {
      socket.emit('joinRoom', {
        'username': username,
        'roomId': roomId,
      });
    }
  }

  //GAME LISTENERS
  void createRoomSuccessListener(BuildContext context) {
    socket.on('createClassicRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(room);
      Navigator.pushNamed(context, GamePage.routeName);
    });
  }

  void joinRoomSuccessListener(BuildContext context) {
    socket.on('joinClassicRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(room);
      Navigator.pushNamed(context, GamePage.routeName);
    });
  }

  void errorOccuredListener(BuildContext context) {
    socket.on('errorOccurred', (data) {
      //
    });
  }

  //FUNCTIONS
  void updatePlayersState(BuildContext context) {
    socket.on('updatePlayers', (playerData) {
      Provider.of<RoomDataProvider>(context, listen: false).updatePlayer1(
        playerData[0],
      );
      Provider.of<RoomDataProvider>(context, listen: false).updatePlayer2(
        playerData[1],
      );
    });
  }
}
