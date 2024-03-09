import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/enums.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  static late IO.Socket authSocket;
  static late IO.Socket lobbySocket;
  static late IO.Socket gameSocket;

  void setup(SocketType type, String name) {
    print('Setup ${type.name} started for $name');
    switch (type) {
      case SocketType.Auth:
        authSocket = IO.io(BASE_URL, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': 'name=$name'
        });
        setSocket(authSocket);
        break;
      case SocketType.Lobby:
        lobbySocket = IO.io("$BASE_URL/lobby", <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': 'name=$name'
        });
        setSocket(lobbySocket);
        break;
      case SocketType.Game:
        gameSocket = IO.io("$BASE_URL/game", <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': 'name=$name'
        });
        setSocket(gameSocket);
        break;
    }
    print("Setup $type.name completed for $name");
  }

  void setSocket(IO.Socket socket) {
    print('Initializing socket');

    print('Calling onConnect socket');
    socket.onConnect((_) {
      print('Connected to server on $BASE_URL');
    });

    print('Calling onConnectError socket');
    socket.onConnectError((data) => print('Connection error: $data'));

    print('Calling onDisconnect socket');
    socket.onDisconnect((_) {
      print('Disconnected from server on $BASE_URL');
    });
  }

  void send<T>(SocketType type, String event, [T? data]) {
    switch (type) {
      case SocketType.Auth:
        authSocket.emit(event, data);
        break;
      case SocketType.Lobby:
        lobbySocket.emit(event, data);
        break;
      case SocketType.Game:
        gameSocket.emit(event, data);
        break;
    }
  }

  void on<T>(SocketType type, String event, Function(T) action) {
    switch (type) {
      case SocketType.Auth:
        authSocket.on(event, (data) => action(data as T));
        break;
      case SocketType.Lobby:
        lobbySocket.on(event, (data) => action(data as T));
        break;
      case SocketType.Game:
        gameSocket.on(event, (data) => action(data as T));
        break;
    }
  }

  void connect(SocketType type, String name) {
    print("Connecting socket $type for $name");
    setup(type, name);
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
    print("Disconnecting socket $type");
    switch (type) {
      case SocketType.Auth:
        authSocket.disconnect();
        break;
      case SocketType.Lobby:
        lobbySocket.disconnect();
        break;
      case SocketType.Game:
        gameSocket.disconnect();
        break;
    }
  }
}
