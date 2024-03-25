import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 3,
      color: kMidOrange.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onPress,
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: kLightGreen.withOpacity(0.1),
          ),
          child: Icon(icon, color: kLight),
        ),
        title: Text(title,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: kLight)),
        trailing: endIcon
            ? Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 18.0, color: kLight),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
