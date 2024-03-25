import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/constants/app_constants.dart';
import 'package:mobile/constants/app_routes.dart';

class SavedGameVideoLibraryPage extends StatefulWidget {
  const SavedGameVideoLibraryPage({super.key});

  static const routeName = HOME_ROUTE;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const SavedGameVideoLibraryPage(),
      settings: RouteSettings(name: routeName),
    );
  }

  @override
  State<SavedGameVideoLibraryPage> createState() => _ReplayVideosPageState();
}

class _ReplayVideosPageState extends State<SavedGameVideoLibraryPage> {
  List videoInfo = [];

  _initData() async {
    await DefaultAssetBundle.of(context)
        .loadString("video_collection_data.json")
        .then((value) {
      setState(() {
        videoInfo = json.decode(value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();
    //_onTapVideo(-1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          kMidGreen.withOpacity(0.9),
          kDarkGreen,
        ],
        begin: const FractionalOffset(0.0, 0.4),
        end: Alignment.topRight,
      )),
      child: Column(
        children: [
          Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child:
                            Icon(Icons.arrow_back_ios, size: 20, color: kLight),
                      ),
                      Expanded(child: Container()),
                      // TODO : delete if not wanted
                      Icon(Icons.info_outline, size: 20, color: kLight),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Collection",
                    style: TextStyle(fontSize: 25, color: kLightOrange),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "de tes vidéos préférées",
                    style: TextStyle(fontSize: 25, color: kDarkOrange),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 90,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                kLime,
                                kDarkGreen,
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 20,
                              color: kMidOrange,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            // TODO: replace with actual duration
                            Text(
                              "X min",
                              style: TextStyle(fontSize: 16, color: kDark),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 250,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [kMidGreen, kDarkGreen],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handyman_outlined,
                              size: 20,
                              color: kMidOrange,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Resistent band, kettebell",
                              style: TextStyle(fontSize: 16, color: kDark),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              )),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(70))),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      "Circuit 1: Legs Toning",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kLight),
                    ),
                    Expanded(child: Container()),
                    Row(
                      children: [
                        Icon(Icons.loop, size: 30, color: kMidGreen),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "3 sets",
                          style: TextStyle(
                            fontSize: 15,
                            color: kMidOrange,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                // Video List view
                Expanded(
                  child: ListView.builder(
                    itemCount: videoInfo.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          debugPrint("Video $index clicked");
                        },
                        child: Container(
                          height: 135,
                          width: 200,
                          color: Colors.redAccent,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                videoInfo[index]['thumbnail']),
                                            fit: BoxFit.cover)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    ));
  }
}
