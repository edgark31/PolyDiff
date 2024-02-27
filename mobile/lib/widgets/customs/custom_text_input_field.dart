import 'package:flutter/material.dart';

class CustomTextInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? helperText;
  final int maxLength;
  final bool isPassword;

  const CustomTextInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLength = 20,
    this.isPassword = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          maxLength: maxLength,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Colors.orange, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
