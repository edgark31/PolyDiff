import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/avatar.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.text,
    this.actions,
  });

  final String? text;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();

    // user avatar
    AvatarProvider.instance.setAccountAvatarUrl(infoService.username);
    final avatarUrl = AvatarProvider.instance.currentAvatarUrl;
    return AppBar(
      backgroundColor: kMidOrange,
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
            onPressed: () => Navigator.pushNamed(context, SEARCH_ROUTE),
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
            child: Avatar(
              imageUrl: avatarUrl,
              radius: 15,
            ),
          ),
        ),
      ],
    );
  }
}
