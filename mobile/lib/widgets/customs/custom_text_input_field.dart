import 'package:flutter/material.dart';

class CustomTextInputField extends StatefulWidget {
  final Function(void)? onInputTextChanged;
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword,
          maxLength: widget.maxLength,
          onChanged: (value) {
            if (widget.onInputTextChanged != null) {
              widget.onInputTextChanged!(value);
            }
          },
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
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
