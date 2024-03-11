// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/temp_images.dart'; // TODO : replace with specific image when http is setup
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/image_converter_service.dart';
import 'package:mobile/services/lobby_service.dart';
import 'package:mobile/widgets/canvas.dart';
import 'package:provider/provider.dart';

class ClassicGamePage extends StatefulWidget {
  static const routeName = CLASSIC_ROUTE;
  ClassicGamePage();

  @override
  State<ClassicGamePage> createState() => _ClassicGamePageState();

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => ClassicGamePage(),
      settings: RouteSettings(name: routeName),
    );
  }
}

class _ClassicGamePageState extends State<ClassicGamePage> {
  final ImageConverterService imageConverterService = ImageConverterService();
  final GameAreaService gameAreaService = GameAreaService();
  late Future<CanvasModel> imagesFuture;

  @override
  void initState() {
    super.initState();
    imagesFuture = loadImage();
  }

  Future<CanvasModel> loadImage() async {
    return imageConverterService.fromImagesBase64(originalImageTempBase64,
        modifiedImageTempBase64); // TODO : replace with specific image when http is setup
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = context.watch<LobbyService>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Row(
            children: [Text('Clock')],
          ),
          SizedBox(height: 10),
          FutureBuilder<CanvasModel>(
            future: imagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OriginalCanvas(snapshot.data, '123'),
                    SizedBox(width: 50),
                    ModifiedCanvas(snapshot.data, '123'),
                  ],
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          // TODO : Add if to only appear if cheating is enabled
          ElevatedButton(onPressed: () {}, child: Text('Mode Triche')),
          // TODO : Remove after testing lobby socket
          ElevatedButton(
              onPressed: () {
                lobbyService.endLobby();
                Navigator.pushNamed(context, DASHBOARD_ROUTE);
              },
              child: Text('Fin de la partie')),
        ],
      ),
    );
  }
}
