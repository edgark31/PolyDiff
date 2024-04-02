
// import 'package:flutter/material.dart';
// import 'package:mobile/constants/app_constants.dart';

// class ReplayPopUp extends StatefulWidget {
//   const ReplayPopUp({super.key});
//   @override
//   _ReplayPopUpState createState() => _ReplayPopUpState();
// }

// class _ReplayPopUpState extends State<ReplayPopUp> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//             padding: EdgeInsets.all(50),
//             child: Column(children: <Widget>[
//               AnimatedButton(
//                 text: "Warning Dialog",
//                 color: kMidOrange,
//                 pressEvent: () {
//                   AwesomeDialog(
//                     context: context,
//                     dialogType: DialogType.warning,
//                     animType: AnimType.topSlide,
//                     showCloseIcon: true,
//                     title: "Warning",
//                     desc: "This is the description of the awesome dialog box",
//                     // actions to perform on cancel and ok buttons
//                     btnCancelOnPress: () {},
//                     // TODO: add a replay button
//                     btnOkOnPress: () {},
//                   );
//                 },
//               )
//             ])),
//       ),
//     );
//   }
// }
