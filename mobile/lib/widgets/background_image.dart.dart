import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({
    super.key,
    this.padding,
    this.margin,
    this.child,
  });

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/MenuBackground.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
