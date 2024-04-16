import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/services/info_service.dart';
import 'package:provider/provider.dart';

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
    final infoService = context.watch<InfoService>();
    final String imagePath = backgroundImagePath ??
        (infoService.isThemeLight
            ? MENU_BACKGROUND_PATH
            : MENU_BACKGROUND_PATH_DARK);

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
