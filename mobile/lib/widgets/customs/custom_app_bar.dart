import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/providers/avatar_provider.dart';
import 'package:mobile/services/info_service.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  late final AvatarProvider _avatarProvider;
  late final InfoService _infoService;

  @override
  void initState() {
    super.initState();

    _avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    _infoService = Provider.of<InfoService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // Optionally listen for changes in infoService if avatar URL might change based on user actions

    return AppBar(
      centerTitle: true,
      titleTextStyle:
          TextStyle(fontSize: 20, color: kLight, fontWeight: FontWeight.bold),
      title: Text(widget.title, style: const TextStyle(letterSpacing: 3)),
      backgroundColor: kMidOrange,
      iconTheme: const IconThemeData(color: kLight),
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
              key: ValueKey(AvatarProvider.instance.currentAvatarUrl),
              backgroundImage: NetworkImage(_avatarProvider.currentAvatarUrl),
              radius: 18.0,
            ),
          ),
        ),
      ],
    );
  }
}
