import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({
    super.key,
    this.imageUrl,
    this.borderColor,
    this.icon = Icons.person,
  });

  final String? imageUrl;
  final Color? borderColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: kLight),
        boxShadow: [
          BoxShadow(
            spreadRadius: 2,
            blurRadius: 10,
            color: kDark.withOpacity(0.1),
          ),
        ],
        shape: BoxShape.circle,
        image: imageUrl != null
            ? DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageUrl!),
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Icon(icon, color: borderColor),
            )
          : null,
    );
  }
}
