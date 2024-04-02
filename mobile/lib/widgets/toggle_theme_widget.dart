import 'package:flutter/material.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ToggleThemeWidget extends StatefulWidget {
  const ToggleThemeWidget({super.key, required this.onToggle});
  final Function(bool) onToggle;

  @override
  State<ToggleThemeWidget> createState() => _ToggleThemeWidgetState();
}

class _ToggleThemeWidgetState extends State<ToggleThemeWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Dark Mode"),
        Switch(
          value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false)
                .toggleTheme(value);
          },
        ),
      ],
    );
  }
}
