import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/models/game_record_model.dart';
import 'package:mobile/replay/game_event_playback_manager.dart';
import 'package:mobile/replay/game_event_slider.dart';
import 'package:mobile/replay/game_events_services.dart';
import 'package:mobile/replay/replay_canvas_widget.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:provider/provider.dart';

class GameEventPlaybackScreen extends StatefulWidget {
  static const String routeName = REPLAY_ROUTE;
  final GameRecord record;

  GameEventPlaybackScreen({required this.record});

  static Route route(GameRecord record) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => GameEventPlaybackScreen(record: record),
    );
  }

  @override
  State<GameEventPlaybackScreen> createState() =>
      _GameEventPlaybackScreenState();
}

class _GameEventPlaybackScreenState extends State<GameEventPlaybackScreen> {
  late GameEventPlaybackService playbackService;
  late GameEventPlaybackManager playbackManager;
  late ReplayImagesProvider replayImagesProvider;
  late GameEventData gameEvent;
  late Timer timer;
  String formattedTime = "00:00";

  @override
  void initState() {
    super.initState();
    // Initialize the playback service
    playbackService = GameEventPlaybackService(defaultGameEvents);
    playbackManager = GameEventPlaybackManager();
    replayImagesProvider = Get.find();

    replayImagesProvider.loadInitialCanvas(context, widget.record);
    replayImagesProvider.preloadGameEventImages(context, widget.record);

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        formattedTime = formattedTime =
            calculateFormattedTime(playbackService.lastEventTime);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playbackService.eventsStream.listen((GameEventData event) {
        print("Event received: ${event.gameEvent}");
        gameEvent = event;
        setState(() {
          formattedTime = calculateFormattedTime(event.timestamp);
        });
      });
    });
  }

  String calculateFormattedTime(DateTime timestamp) {
    // Calculate elapsed time since the start of the playback
    Duration elapsedTime =
        timestamp.difference(playbackService.events.first.timestamp);
    // Calculate minutes and seconds from the elapsed time
    int minutes = elapsedTime.inMinutes;
    int seconds = elapsedTime.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ReplayImagesProvider replayImagesProvider =
        context.watch<ReplayImagesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Event Playback"),
      ),
      body: Column(
        children: [
          // Display the formatted time
          Text(
            'Time: $formattedTime',
            style: TextStyle(fontSize: 18),
          ),
          FutureBuilder<CanvasModel>(
            future: replayImagesProvider.currentCanvas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ReplayOriginalCanvas(snapshot.data),
                    SizedBox(width: 50),
                    ReplayModifiedCanvas(snapshot.data),
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          Center(
            child: GameEventSlider(
              playbackService: playbackService,
              playbackManager: playbackManager,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    playbackService.dispose();
    super.dispose();
  }
}
