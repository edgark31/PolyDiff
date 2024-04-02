import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/models/friend_model.dart';

class FriendsPopup extends StatefulWidget {
  final List<Friend?> allFriends;
  final List<Friend?> commonFriends;
  final String username;

  FriendsPopup(
      {Key? key,
      required this.username,
      required this.allFriends,
      required this.commonFriends})
      : super(key: key);

  @override
  State<FriendsPopup> createState() => _FriendsPopupState();
}

class _FriendsPopupState extends State<FriendsPopup> {
  bool showAllFriends = true;

  @override
  Widget build(BuildContext context) {
    List<Friend?> friendsToShow =
        showAllFriends ? widget.allFriends : widget.commonFriends;

    return Dialog(
      child: SizedBox(
        width: 500,
        height: 700,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.commonFriends.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: kLightGreen,
                    disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  ),
                  onPressed: () {
                    setState(() {
                      showAllFriends = !showAllFriends;
                    });
                  },
                  child: Text(showAllFriends
                      ? 'Voir les amis en commun'
                      : 'Voir tous les amis'),
                ),
              ),
            ],
            Text("Liste d'amis à ${widget.username}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            Expanded(
              child: ListView.builder(
                itemCount: friendsToShow.length,
                itemBuilder: (context, index) {
                  final friend = friendsToShow[index];

                  return Container(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 430),
                      child: Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: AssetImage(
                                'assets/images/hallelujaRaccoon.jpeg'),
                          ),
                          title: Text(friend!.name,
                              style: TextStyle(fontSize: 25)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
