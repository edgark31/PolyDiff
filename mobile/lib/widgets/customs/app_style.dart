import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

TextStyle appstyle(double size, Color color, FontWeight fontWeight) {
  return TextStyle(fontSize: size, color: color, fontWeight: fontWeight);
  // return GoogleFonts.poppins(
  //     fontSize: size, color: color, fontWeight: fontWeight);
}

const TextStyle kHeading = TextStyle(
  fontSize: 60,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kBodyText = TextStyle(
  fontSize: 22,
  color: Colors.white,
);
