import 'package:flutter/material.dart';
import 'package:mobile/widgets/widgets.dart';

class WaitingLobby extends StatefulWidget {
  const WaitingLobby({super.key});

  State<WaitingLobby> createState() => _WaitingLobbyState();
}

class _WaitingLobbyState extends State<WaitingLobby> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('En attente de joueurs pour démarrer la partie'),
        const SizedBox(height: 20),
      ],
    );
  }
}
