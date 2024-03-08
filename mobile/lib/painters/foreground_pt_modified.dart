import 'package:flutter/material.dart';
import 'package:mobile/models/canvas_model.dart';

//TODO: Make calls for validation
class ForegroundPtOriginal extends CustomPainter {
  final CanvasModel images;

  ForegroundPtOriginal(this.images); //

  @override
  void paint(Canvas canvas, Size size) {
   
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
