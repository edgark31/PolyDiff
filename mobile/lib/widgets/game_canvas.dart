import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/models/canvas_model.dart';

abstract class GameCanvas extends StatelessWidget {
  final CanvasModel images;

  static const double tabletScalingRatio = 0.8;

  GameCanvas(this.images);

  final RxDouble x = 0.0.obs;
  final RxDouble y = 0.0.obs;
}
