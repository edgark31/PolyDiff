/*
  create constant color for the button and renamed as you want
*/
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color backgroundColor, textColor;
  const CustomButton({
    required this.text,
    required this.press,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: ElevButton(),
      ),
    );
  }

  Widget ElevButton() {
    return ElevatedButton(
      onPressed: () => press(),
      style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          textStyle: TextStyle(
              color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
//