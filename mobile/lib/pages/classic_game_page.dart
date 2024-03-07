// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/canvas_model.dart';
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
  late Future<CanvasModel> imagesFuture;

  @override
  void initState() {
    super.initState();
    imagesFuture = loadImage();
  }

  Future<CanvasModel> loadImage() async {
    String imagePath = 'assets/images/raton-laveur.bmp';
    return imageConverterService.fromImagePath(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Row(
            children: [Text('Clock')],
          ),
          SizedBox(height: 10),
          AbsorbPointer(
            child: FutureBuilder<CanvasModel>(
              future: imagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ModifiedCanvas(snapshot.data, '123'),
                      OriginalCanvas(snapshot.data, '123'),
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
