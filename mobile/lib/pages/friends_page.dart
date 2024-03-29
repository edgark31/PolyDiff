import 'package:flutter/material.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';
import 'package:mobile/models/friend_model.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/widgets/customs/custom_app_bar.dart';
import 'package:mobile/widgets/customs/custom_menu_drawer.dart';

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
                            print("Show friends");
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                            disabledForegroundColor:
                                Colors.grey.withOpacity(0.38),
                          ),
                          child: Text('Amis', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                    subtitle: Text(friend.isOnline ? 'Online' : 'Offline'),
                    onTap: () {
                      print("Pressed");
                    },
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
        return Text("Contenu pour En attente");
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
      body: Column(
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
    );
  }
}
