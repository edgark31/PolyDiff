import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/socket_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  static const routeName = JOIN_ROOM_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const JoinRoomPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final SocketService _socketService = SocketService();
  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  void initState() {
    _socketService.joinRoomSuccessListener(context);
    _socketService.errorOccuredListener(context);
    _socketService.updatePlayersState(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.045),
            CustomButton(
              text: 'Créer une salle',
              press: () => _socketService.joinRoom('mj', '1'),
              backgroundColor: kMidOrange,
            ),
          ],
        ),
      ),
    );
  }
}
