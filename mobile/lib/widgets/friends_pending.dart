import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/services/friend_service.dart';
import 'package:provider/provider.dart';

class FriendsPending extends StatefulWidget {
  @override
  State<FriendsPending> createState() => _FriendsPending();
}

class _FriendsPending extends State<FriendsPending> {
  @override
  void initState() {
    final FriendService friendService = Get.find();
    super.initState();
    friendService.fetchSent();
    friendService.fetchPending();
  }

  @override
  Widget build(BuildContext context) {
    final FriendService friendService = context.watch<FriendService>();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Liste de demande d'amis en attente reçues",
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: friendService.pendingFriends.length,
            itemBuilder: (BuildContext context, int index) {
              final friend = friendService.pendingFriends[index];
              String avatarURL = '$BASE_URL/avatar/${friend.accountId}.png';
              return Container(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(avatarURL),
                      ),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(friend.name, style: TextStyle(fontSize: 25)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            color: const Color.fromARGB(255, 2, 173, 90),
                            iconSize: 40,
                            icon: Icon(Icons.person_add),
                            onPressed: () {
                              print("Accepted Friend invite");
                            },
                          ),
                          SizedBox(width: 50),
                          IconButton(
                            color: Colors.redAccent,
                            iconSize: 40,
                            icon: Icon(Icons.person_remove),
                            onPressed: () {
                              print("Unaccepted Friend invite");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            child: Text(
              "Liste de demande d'amis en attente envoyées",
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: friendService.sentFriends.length,
            itemBuilder: (BuildContext context, int index) {
              final friend = friendService.sentFriends[index];
              String avatarURL = '$BASE_URL/avatar/${friend.accountId}.png';
              return Container(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(avatarURL),
                      ),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(friend.name, style: TextStyle(fontSize: 25)),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          friendService.cancelInvite(friend.accountId);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: kLightGreen,
                          disabledForegroundColor:
                              Colors.grey.withOpacity(0.38),
                        ),
                        child: Text('Annuler', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
