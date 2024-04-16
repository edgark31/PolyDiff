import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onPress,
        leading: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon),
        ),
        title: Text(
          title,
        ),
        trailing: endIcon
            ? Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 18.0),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
