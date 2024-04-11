import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_event_slider.dart';
import 'package:mobile/replay/game_events_services.dart';

class GameEventPlaybackScreen extends StatefulWidget {
  static const String routeName = REPLAY_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => GameEventPlaybackScreen(),
    );
  }

  @override
  State<GameEventPlaybackScreen> createState() =>
      _GameEventPlaybackScreenState();
}

class _GameEventPlaybackScreenState extends State<GameEventPlaybackScreen> {
  late GameEventPlaybackService playbackService;
  late GameEventPlaybackManager playbackManager;
  late GameEventData gameEvent;

  @override
  void initState() {
    super.initState();
    // Initialize the playback service with test game events data
    playbackService = GameEventPlaybackService(getTestGameEventsData());
    playbackManager = GameEventPlaybackManager();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playbackService.eventsStream.listen((GameEventData event) {
        print("Event received: ${event.gameEvent}");
        gameEvent = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Event Playback"),
      ),
      body: Center(
        child: GameEventSlider(
          playbackService: playbackService,
          playbackManager: playbackManager,
        ),
      ),
    );
  }

  @override
  void dispose() {
    playbackService.dispose();
    super.dispose();
  }
}
