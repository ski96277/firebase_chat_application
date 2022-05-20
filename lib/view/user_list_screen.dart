import 'dart:developer';

import 'package:firebase_chat_application/firebaseQuery/firebase_quiery.dart';
import 'package:firebase_chat_application/model/user_info.dart';
import 'package:firebase_chat_application/view/message_details_screen.dart';
import 'package:firebase_chat_application/widget/list_item.dart';
import 'package:flutter/material.dart';


class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserInfoDetails> userInfoDetailsList = [];
  bool loadingUserInfo = true;

  @override
  Widget build(BuildContext context) {
    return loadingUserInfo
        ? const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()))
        : userInfoDetailsList.isEmpty
            ? const Center(
                child: Text("No user found"),
              )
            : ListView.builder(
                itemCount: userInfoDetailsList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDetailsScreen(senderDetails: userInfoDetailsList[index])));
                    },
                    child: ListItem(
                      title: userInfoDetailsList[index].name,
                      subTile: "Dhaka,BD",
                    ),
                  );
                },
              );
  }

  @override
  void initState() {
    super.initState();
    FirebaseQuiery.getUserList((userInfoDetailsList) {
      log("length is ${userInfoDetailsList.length}");

      this.userInfoDetailsList = userInfoDetailsList;
      loadingUserInfo = false;
      try{
        setState(() {});
      }catch(e){}

    });
  }
}
