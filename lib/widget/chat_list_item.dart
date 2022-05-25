import 'dart:developer';

import 'package:firebase_chat_application/widget/circular_image.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  String? title;
  String? subTile;
  int? unReadMessage;
  int? messageType;

  ChatListItem({this.title, this.subTile, this.unReadMessage, this.messageType});

  @override
  Widget build(BuildContext context) {
    log("message messageType =  $messageType");
    return Container(
      decoration: BoxDecoration(color: unReadMessage! > 0 ? Colors.grey[350] : Colors.grey[200], borderRadius: const BorderRadius.all(Radius.circular(10))),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          CircularImage(placeHolder: "assets/icon/profile.png", imageUrlLink: "https://www.dmarge.com/wp-content/uploads/2021/01/dwayne-the-rock-.jpg"),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                messageType==1?subTile!:"sent an image",
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          const Spacer(),
          unReadMessage! > 0
              ? Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Center(
                      child: Text(
                    "$unReadMessage",
                    style: const TextStyle(color: Colors.white),
                  )))
              : const SizedBox()
        ],
      ),
    );
  }
}
