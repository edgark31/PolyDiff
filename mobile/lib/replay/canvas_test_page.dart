import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/command/canvas_command.dart';
import 'package:mobile/constants/app_routes.dart';

class CanvasAreaPainter extends CustomPainter {
  final List<Offset> differences;
  final double circleRadius = 20.0;
  final Color circleColor = Colors.red;
  CanvasAreaPainter(this.differences);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the circles
    final paint = Paint()..color = circleColor;

    // Draw each difference as a circle
    for (final diff in differences) {
      canvas.drawCircle(diff, circleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasAreaPainter oldDelegate) {
    return oldDelegate.differences == differences;
  }
}

class InteractiveCanvasWidget extends StatefulWidget {
  const InteractiveCanvasWidget({super.key});

  static const routeName = CANVAS_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const InteractiveCanvasWidget(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<InteractiveCanvasWidget> createState() =>
      _InteractiveCanvasWidgetState();
}

class _InteractiveCanvasWidgetState extends State<InteractiveCanvasWidget> {
  late CanvasReceiver canvas;
  late CanvasDifference _canvasDifference;

  @override
  void initState() {
    super.initState();
    canvas = CanvasReceiver();
    _canvasDifference = CanvasDifference(canvas);
  }

  void _handleTap(Offset tapPosition) {
    final tappedDifference = canvas.differences.firstWhereOrNull((difference) {
      return (tapPosition - difference).distance <= 20.0;
    });

    if (tappedDifference != null) {
      _canvasDifference.perform(
          CanvasActions.removeDifference, tappedDifference);
      canvas.removeDifference(tappedDifference);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        _handleTap(localPosition);
      },
      child: CustomPaint(
        painter: CanvasAreaPainter(canvas.differences),
        child: Container(height: 100),
      ),
    );
  }
}
