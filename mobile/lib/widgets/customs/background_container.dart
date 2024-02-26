import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({
    super.key,
    this.padding,
    this.margin,
    this.child,
    this.backgroundImagePath,
  });

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? child;
  final String? backgroundImagePath;

  @override
  Widget build(BuildContext context) {
    final String imagePath = backgroundImagePath ?? MENU_BACKGROUND_PATH;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
