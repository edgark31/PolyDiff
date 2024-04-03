import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/services/friend_service.dart';
import 'package:mobile/services/info_service.dart';
import 'package:mobile/widgets/friends_popup.dart';
import 'package:provider/provider.dart';

class FriendsSearch extends StatefulWidget {
  @override
  State<FriendsSearch> createState() => _FriendsSearchState();
}

class _FriendsSearchState extends State<FriendsSearch> {
  final FriendService friendService = Get.find();

  TextEditingController usernameController = TextEditingController();
  FocusNode textFocusNode = FocusNode();
  bool isTyping = false;
  List<User> searchedUsers = [];

  @override
  void initState() {
    super.initState();
    friendService.fetchUsers();
    friendService.fetchPending();
  }

  void _handleUsernameSubmit(String username) {
    friendService.fetchUsers();
    if (username.isNotEmpty && username.trim().isNotEmpty) {
      setState(() {
        searchedUsers = (friendService.users)
            .where((user) =>
                user.name.toLowerCase().contains(username.toLowerCase()))
            .toList();
      });
      FocusScope.of(context).requestFocus(textFocusNode);
    } else {
      setState(() {
        searchedUsers = [];
      });
    }
  }

  Widget _state(String myId, User user) {
    bool isFriend = user.friends.any((friend) => friend!.accountId == myId);
    if (isFriend) {
      return Text('Ami', style: TextStyle(fontSize: 18));
    } else {
      if (user.friendRequests.contains(myId)) {
        return TextButton(
          onPressed: () {
            print("Cancelled request");
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: kLightGreen,
            disabledForegroundColor: Colors.grey.withOpacity(0.38),
          ),
          child: Text('Annuler', style: TextStyle(fontSize: 18)),
        );
      } else {
        bool isPending = friendService.pendingFriends
            .any((friend) => friend.accountId == user.accountId);
        if (isPending) {
          Row(
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
          );
        } else {
          return TextButton(
            onPressed: () {
              friendService.sendInvite(user.accountId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: kLightGreen,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
            ),
            child: Text('Inviter', style: TextStyle(fontSize: 18)),
          );
        }
      }
    }
    return Text("ERROR");
  }

  @override
  Widget build(BuildContext context) {
    final infoService = context.watch<InfoService>();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Container(
              width: 520,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: textFocusNode,
                      controller: usernameController,
                      onChanged: (text) {
                        setState(() {
                          isTyping = text.isNotEmpty;
                          _handleUsernameSubmit(usernameController.text);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Entrez le nom d'un utilisateur",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.black,
                      ),
                      onSubmitted: _handleUsernameSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchedUsers.length,
            itemBuilder: (BuildContext context, int index) {
              final user = searchedUsers[index];
              String avatarURL = '$BASE_URL/avatar/${user.accountId}.png';
              return Container(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520),
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
                          Text(user.name, style: TextStyle(fontSize: 25)),
                          SizedBox(width: 20),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FriendsPopup(
                                    username: user.name,
                                    allFriends: user.friends,
                                    commonFriends: [], // Ok for now because this is not the real logic
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: kLightGreen,
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.38),
                            ),
                            child: Text('Amis', style: TextStyle(fontSize: 25)),
                          ),
                        ],
                      ),
                      trailing: _state(infoService.id, user),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
