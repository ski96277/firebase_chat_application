import 'package:firebase_chat_application/widget/circular_image.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
String? title;
String? subTile;


ListItem({this.title, this.subTile});

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: const EdgeInsets.all(10),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                subTile!,
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
