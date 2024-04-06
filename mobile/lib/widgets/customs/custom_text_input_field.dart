import 'package:flutter/material.dart';

class CustomTextInputField extends StatefulWidget {
  final Function(String)? onInputTextChanged;
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? helperText;
  final String? errorText;
  final int maxLength;
  final bool isPassword;

  CustomTextInputField({
    super.key,
    this.onInputTextChanged,
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLength = 20,
    this.isPassword = false,
    this.helperText,
    this.errorText,
  });

  @override
  State<CustomTextInputField> createState() => _CustomTextInputFieldState();
}

class _CustomTextInputFieldState extends State<CustomTextInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: 100),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword,
          maxLength: widget.maxLength,
          onChanged: widget.onInputTextChanged,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            hintText: widget.hint,
            hintStyle: TextStyle(
                color: Color.fromARGB(255, 192, 190, 190),
                fontWeight: FontWeight.bold),
            helperText: widget.helperText,
            helperStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
            errorText: widget.errorText,
            errorStyle:
                TextStyle(color: Colors.red, backgroundColor: Colors.white),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
