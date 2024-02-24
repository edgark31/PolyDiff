import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/widgets/customs/app_style.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    super.key,
    required this.icon,
    required this.hint,
    required this.inputAction,
    this.controller,
  });

  final IconData icon;
  final String hint;
  final TextInputAction inputAction;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: kMidGreen.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: InputBorder.none,
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            hintStyle: kBodyText,
          ),
          obscureText: true,
          style: kBodyText,
          textInputAction: inputAction,
        ),
      ),
    );
  }
}
