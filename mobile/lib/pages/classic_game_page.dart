// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/constants/temp_images.dart'; // TODO : replace with specific image when http is setup
import 'package:mobile/models/canvas_model.dart';
import 'package:mobile/services/game_area_service.dart';
import 'package:mobile/services/image_converter_service.dart';
import 'package:mobile/widgets/canvas.dart';

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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GAME_BACKGROUND_PATH),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.vpn_key),
                  iconSize: 40.0,
                  color: Colors.black,
                  onPressed: () {
                    print('Activate Cheat');
                  },
                ),
                SizedBox(
                  height: 200,
                  width: 1000,
                  //child:
                ), // TODO: Add game infos as a child in the SizedBox when ready
              ],
            ),
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
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.wechat_sharp),
                    iconSize: 45.0,
                    color: Colors.white,
                    onPressed: () {
                      print('Chat icon pressed');
                    },
                  ),
                ),
                Positioned(
                  left: 8.0,
                  top: 0,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Abandonner button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF2D1E16),
                      onPrimary: Color(0xFFEF6151),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Abandonner',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
