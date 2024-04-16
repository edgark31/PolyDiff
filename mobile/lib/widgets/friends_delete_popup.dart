import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:mobile/services/friend_service.dart';
import 'package:mobile/widgets/customs/custom_btn.dart';
import 'package:provider/provider.dart';

class FriendsDeletePopup extends StatelessWidget {
  final FriendService friendService = Get.find();
  final String accountId;
  FriendsDeletePopup({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final friendService = context.watch<FriendService>();
    return Center(
      child: SizedBox(
        width: 600.0,
        height: 500.0,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/woodenPopUp.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.friendList_questionTitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              CustomButton(
                text: AppLocalizations.of(context)!.confirmation_yes,
                press: () {
                  if(!friendService.isDeleteDisabled) {
                  friendService.removeFriend(accountId);
                  Navigator.pop(context);
                  }
                },
              ),
              SizedBox(height: 10),
              CustomButton(
                text: AppLocalizations.of(context)!.confirmation_no,
                press: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
