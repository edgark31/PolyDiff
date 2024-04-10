import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/replay/replay_images_provider.dart';
import 'package:provider/provider.dart';

class ReplayCanvasWidget extends StatefulWidget {
  @override
  State<ReplayCanvasWidget> createState() => _ReplayCanvasWidgetState();
}

class _ReplayCanvasWidgetState extends State<ReplayCanvasWidget> {
  ReplayImagesProvider replayImagesProvider = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final replayImagesProvider = Provider.of<ReplayImagesProvider>(context);
    replayImagesProvider.getCurrentCanvasImage();
    return Container();
  }
}
