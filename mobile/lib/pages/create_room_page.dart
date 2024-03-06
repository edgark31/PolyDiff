import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/services.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  static const routeName = CREATE_ROOM_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const CreateRoomPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final SocketService _socketService = SocketService();

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  void initState() {
    super.initState();
    _socketService.createRoomSuccessListener(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
