import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/friend_service.dart';
import 'package:mobile/widgets/friends_popup.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatefulWidget {
  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  void initState() {
    final FriendService friendService = Get.find();
    super.initState();
    friendService.fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    final friendService = context.watch<FriendService>();
    return ListView.builder(
      itemCount: friendService.friends.length,
      itemBuilder: (BuildContext context, int index) {
        final friend = friendService.friends[index];
        String avatarURL = '$BASE_URL/avatar/${friend.accountId}.png';
        return Container(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 750),
            child: Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(avatarURL),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.circle,
                          color: friend.isOnline ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(friend.name, style: TextStyle(fontSize: 25)),
                    SizedBox(width: 5),
                    IconButton(
                      icon: Icon(
                        friend.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: friend.isFavorite ? Colors.red : null,
                        size: 35,
                      ),
                      onPressed: () {
                        if (friend.isFavorite) {
                          friendService.toggleFavorite(friend.accountId, false);
                        } else {
                          friendService.toggleFavorite(friend.accountId, true);
                        }
                      },
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        friendService.fetchFoFs(friend.accountId);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return FriendsPopup(
                              username: friend.name,
                              accountId: friend.accountId,
                              inSearch: false,
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: kLightGreen,
                        disabledForegroundColor: Colors.grey.withOpacity(0.38),
                      ),
                      child: Text(
                          AppLocalizations.of(context)!.friendList_friendButton,
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
                subtitle: Text(friend.isOnline
                    ? AppLocalizations.of(context)!.friendList_isOnline
                    : AppLocalizations.of(context)!.friendList_isOffline),
                trailing: IconButton(
                  iconSize: 40,
                  icon: Icon(Icons.person_remove),
                  onPressed: () {
                    friendService.removeFriend(friend.accountId);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
