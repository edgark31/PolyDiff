import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/replay/replay_notifier.dart';

class WatchGameReplayPage extends StatefulWidget {
  static const routeName = PRACTICE_ROUTE;

  @override
  State<WatchGameReplayPage> createState() => _WatchGameReplayPageState();

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => WatchGameReplayPage(),
      settings: RouteSettings(name: routeName),
    );
  }
}

class _WatchGameReplayPageState extends State<WatchGameReplayPage> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.endGameListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Game Replay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('Watch Game Replay'),
          ],
        ),
      ),
    );
  }
}
