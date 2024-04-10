import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/painters/background_pt_modified.dart';
import 'package:mobile/painters/background_pt_original.dart';
import 'package:mobile/painters/foreground_pt_modified.dart';
import 'package:mobile/painters/foreground_pt_original.dart';
import 'package:mobile/providers/game_record_provider.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:mobile/replay/replay_service.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/widgets/game_canvas.dart';
import 'package:provider/provider.dart';

class ReplayOriginalCanvas extends GameCanvas {
  final GameAreaService gameAreaService = Get.find();

  ReplayOriginalCanvas(
    images,
  ) : super(images);

  @override
  Widget build(BuildContext context) {
    final gameAreaService = Provider.of<GameAreaService>(context);

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 3.0,
            ),
          ),
          child: GestureDetector(
            onTapUp: (details) {
              return;
            },
            child: SizedBox(
              width: images.original.width.toDouble() *
                  GameCanvas.tabletScalingRatio,
              height: images.original.height.toDouble() *
                  GameCanvas.tabletScalingRatio,
              child: CustomPaint(
                painter: BackgroundPtOriginal(images),
                foregroundPainter:
                    ForegroundPtOriginal(images, gameAreaService),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReplayModifiedCanvas extends GameCanvas {
  ReplayModifiedCanvas(
    images,
  ) : super(images);

  @override
  Widget build(BuildContext context) {
    final GameAreaService gameAreaService =
        Provider.of<GameAreaService>(context);
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 3.0,
            ),
          ),
          child: GestureDetector(
            onTapUp: (details) {
              return;
            },
            child: SizedBox(
              width: images.original.width.toDouble() *
                  GameCanvas.tabletScalingRatio,
              height: images.original.height.toDouble() *
                  GameCanvas.tabletScalingRatio,
              child: CustomPaint(
                painter: BackgroundPtModified(images),
                foregroundPainter:
                    ForegroundPtModified(images, gameAreaService),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MyImageScreen extends StatefulWidget {
  static const routeName = REPLAY_ROUTE;

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => MyImageScreen(),
    );
  }

  @override
  State<MyImageScreen> createState() => _MyImageScreenState();
}

class _MyImageScreenState extends State<MyImageScreen> {
  final ReplayService replayService = Get.find<ReplayService>();
  final ReplayImagesProvider replayImagesProvider =
      Get.find<ReplayImagesProvider>();

  final GameRecordProvider gameRecordProvider = Get.find<GameRecordProvider>();

  @override
  void initState() {
    super.initState();
    gameRecordProvider.getDefault();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadImages();
      loadImage();
    });
    replayService.start();
  }

  void preloadImages() async {
    final ReplayService replayService =
        Provider.of<ReplayService>(context, listen: false);
    await replayService.preloadGameEventImages(context);
  }

  void loadImage() async {
    final ReplayService replayService =
        Provider.of<ReplayService>(context, listen: false);
    await replayService.loadInitialCanvas(context);
  }

  @override
  Widget build(BuildContext context) {
    ReplayImagesProvider replayImagesProvider =
        context.watch<ReplayImagesProvider>();

    return Scaffold(
      body: FutureBuilder<CanvasModel>(
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
    );
  }
}
