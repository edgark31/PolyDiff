import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/customs/app_style.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    // user avatar
    AvatarProvider.instance.setAccountAvatarUrl(infoService.id);
    final avatarUrl = AvatarProvider.instance.currentAvatarUrl;
    return AppBar(
      centerTitle: true,
      titleTextStyle: appstyle(20, kLight, FontWeight.bold),
      title: Text(title, style: TextStyle(letterSpacing: 3)),
      backgroundColor: kMidOrange,
      iconTheme: IconThemeData(color: kLight),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamed(context, DASHBOARD_ROUTE),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, SEARCH_FRIEND_ROUTE),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: const Icon(Icons.message_rounded),
            onPressed: () => Navigator.pushNamed(context, CHAT_ROUTE),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, PROFILE_ROUTE),
            child: CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
              radius: 18.0,
            ),
          ),
        ),
      ],
    );
  }
}
