import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/friend_model.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_menu_drawer.dart';
import 'package:mobile/widgets/friends_popup.dart';

class FriendsPage extends StatefulWidget {
  static const routeName = FRIENDS_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => FriendsPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int _selectedViewIndex = 0;
  List<Friend> simulatedFriends = [
    Friend(
        username: "Mp",
        id: "11",
        friends: [
          Friend(
              username: "AHHH",
              id: "17",
              friends: [],
              commonFriends: [],
              isOnline: true,
              isFavorite: false),
          Friend(
              username: "Edgar",
              id: "14",
              friends: [],
              commonFriends: [],
              isOnline: false,
              isFavorite: false),
          Friend(
              username: "Mj",
              id: "13",
              friends: [],
              commonFriends: [],
              isOnline: true,
              isFavorite: false),
        ],
        commonFriends: [
          Friend(
              username: "Zaki",
              id: "15",
              friends: [],
              commonFriends: [],
              isOnline: true,
              isFavorite: false),
          Friend(
              username: "Moh",
              id: "16",
              friends: [],
              commonFriends: [],
              isOnline: true,
              isFavorite: false),
        ],
        isOnline: true,
        isFavorite: false),
    Friend(
        username: "Edgar",
        id: "14",
        friends: [],
        commonFriends: [],
        isOnline: false,
        isFavorite: false),
    Friend(
        username: "Mj",
        id: "13",
        friends: [],
        commonFriends: [],
        isOnline: true,
        isFavorite: false),
    Friend(
        username: "Zaki",
        id: "15",
        friends: [],
        commonFriends: [],
        isOnline: true,
        isFavorite: false),
    Friend(
        username: "Moh",
        id: "16",
        friends: [],
        commonFriends: [],
        isOnline: true,
        isFavorite: false),
  ];
  //simulatedRequestsReceived and simulatedRequestsSent won't have this version of Friend
  List<Friend> simulatedRequestsReceived = [
    Friend(
        username: "Zaki",
        id: "15",
        friends: [],
        commonFriends: [],
        isOnline: true,
        isFavorite: false),
    Friend(
        username: "Mj",
        id: "13",
        friends: [],
        commonFriends: [],
        isOnline: true,
        isFavorite: false),
  ];

  List<Friend> simulatedRequestsSent = [
    Friend(
        username: "Edgar",
        id: "14",
        friends: [],
        commonFriends: [],
        isOnline: false,
        isFavorite: false),
  ];

  //Utilisé pour la recherche
  List<UserFriend> simulatedUsers = [
    UserFriend(username: "Mp", id: "11", friends: [], friendRequests: []),
    UserFriend(username: "Mj", id: "13", friends: [], friendRequests: []),
    UserFriend(username: "Edgar", id: "14", friends: [], friendRequests: []),
    UserFriend(username: "Moha", id: "15", friends: [], friendRequests: []),
    UserFriend(username: "Zaki", id: "16", friends: [], friendRequests: []),
  ];

  void _selectView(int index) {
    setState(() {
      _selectedViewIndex = index;
    });
  }

// TODO: When the real connection is done, move each returned widget into separate files
  Widget _buildContent() {
    switch (_selectedViewIndex) {
      case 0:
        return ListView.builder(
          itemCount: simulatedFriends.length,
          itemBuilder: (BuildContext context, int index) {
            final friend = simulatedFriends[index];
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
                          backgroundImage:
                              AssetImage('assets/images/hallelujaRaccoon.jpeg'),
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
                              color:
                                  friend.isOnline ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(friend.username, style: TextStyle(fontSize: 25)),
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
                            setState(() {
                              friend.isFavorite = !friend.isFavorite;
                            });
                            // TODO: notify the server
                          },
                        ),
                        SizedBox(width: 20),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FriendsPopup(
                                  username: friend.username,
                                  allFriends: friend.friends,
                                  commonFriends: friend.commonFriends,
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
                          child: Text('Amis', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                    subtitle: Text(friend.isOnline ? 'Online' : 'Offline'),
                    trailing: IconButton(
                      iconSize: 40,
                      icon: Icon(Icons.person_remove),
                      onPressed: () {
                        print("delete ${friend.username}");
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case 1:
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
                itemCount: simulatedRequestsReceived.length,
                itemBuilder: (BuildContext context, int index) {
                  final friend = simulatedRequestsReceived[index];
                  return Container(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: AssetImage(
                                'assets/images/hallelujaRaccoon.jpeg'),
                          ),
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(friend.username,
                                  style: TextStyle(fontSize: 25)),
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
                itemCount: simulatedRequestsSent.length,
                itemBuilder: (BuildContext context, int index) {
                  final friend = simulatedRequestsSent[index];
                  return Container(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 500),
                      child: Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: AssetImage(
                                'assets/images/hallelujaRaccoon.jpeg'),
                          ),
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(friend.username,
                                  style: TextStyle(fontSize: 25)),
                            ],
                          ),
                          trailing: TextButton(
                            onPressed: () {
                              print("Cancelled request");
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: kLightGreen,
                              disabledForegroundColor:
                                  Colors.grey.withOpacity(0.38),
                            ),
                            child:
                                Text('Annuler', style: TextStyle(fontSize: 18)),
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
      case 2:
        return Text("Contenu pour Ajouter un ami");
      default:
        return Text("Contenu non disponible");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomMenuDrawer(),
      appBar: CustomAppBar(title: "Page d'amis"),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/LimitedTimeBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  ElevatedButton(
                    onPressed: () => _selectView(i),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (_selectedViewIndex == i) {
                            return Color.fromARGB(255, 2, 70, 22);
                          } else {
                            return kLightGreen;
                          }
                        },
                      ),
                    ),
                    child: Text(
                        i == 0
                            ? "Tous les amis"
                            : (i == 1 ? "En attente" : "Ajouter un ami"),
                        style: TextStyle(fontSize: 25, color: Colors.white)),
                  ),
                ]
              ],
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }
}
