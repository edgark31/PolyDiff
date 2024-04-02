import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  static IO.Socket? authSocket;
  static IO.Socket? lobbySocket;
  static IO.Socket? gameSocket;

  void setup(SocketType type, String id) {
    bool isConnected = false;

    switch (type) {
      case SocketType.Auth:
        if (authSocket != null && authSocket!.connected) {
          isConnected = true;
        }
        break;
      case SocketType.Lobby:
        if (lobbySocket != null && lobbySocket!.connected) {
          isConnected = true;
        }
        break;
      case SocketType.Game:
        if (gameSocket != null && gameSocket!.connected) {
          isConnected = true;
        }
        break;
    }

    if (isConnected) {
      print("${type.name} socket is already connected. Skipping setup.");
      return;
    }

    switch (type) {
      case SocketType.Auth:
        authSocket = IO.io(BASE_URL, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'forceNew': true,
          'query': 'id=$id'
        });
        authSocket!.connect();
        setSocket(authSocket!);
        break;
      case SocketType.Lobby:
        lobbySocket = IO.io("$BASE_URL/lobby", <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'forceNew': true,
          'query': 'id=$id'
        });
        lobbySocket!.connect();
        setSocket(lobbySocket!);
        break;
      case SocketType.Game:
        gameSocket = IO.io("$BASE_URL/game", <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'forceNew': true,
          'query': 'id=$id',
        });
        gameSocket!.connect();
        setSocket(gameSocket!);
        break;
    }
    print("Setup ${type.name} completed for $id");
  }

  void setSocket(IO.Socket socket) {
    socket.onConnect((_) {
      print('Connected to server on $BASE_URL');
      print("Connected socket id : ${socket.id}");
    });

    socket.onConnectError((data) {
      print("Connection error for socket id : ${socket.id}");
      print('Connection error: $data');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server on $BASE_URL');
    });
  }

  void send<T>(SocketType type, String event, [T? data]) {
    switch (type) {
      case SocketType.Auth:
        authSocket!.emit(event, data);
        break;
      case SocketType.Lobby:
        lobbySocket!.emit(event, data);
        break;
      case SocketType.Game:
        gameSocket!.emit(event, data);
        break;
    }
  }

  void on<T>(SocketType type, String event, Function(T) action) {
    switch (type) {
      case SocketType.Auth:
        authSocket!.on(event, (data) => action(data as T));
        break;
      case SocketType.Lobby:
        lobbySocket!.on(event, (data) => action(data as T));
        break;
      case SocketType.Game:
        gameSocket!.on(event, (data) => action(data as T));
        break;
    }
  }

  void disconnect(SocketType type) {
    print("Disconnecting socket $type");
    switch (type) {
      case SocketType.Auth:
        authSocket!.disconnect();
        authSocket!.clearListeners();
        break;
      case SocketType.Lobby:
        lobbySocket!.disconnect();
        lobbySocket!.clearListeners();
        break;
      case SocketType.Game:
        gameSocket!.disconnect();
        gameSocket!.clearListeners();
        break;
    }
  }
}
