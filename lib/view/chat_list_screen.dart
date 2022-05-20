import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/firebaseQuery/firebase_quiery.dart';
import 'package:firebase_chat_application/model/room_info.dart';
import 'package:firebase_chat_application/model/user_info.dart';
import 'package:firebase_chat_application/view/message_details_screen.dart';
import 'package:firebase_chat_application/widget/chat_list_item.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<RoomInfo> roomInfoList;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    FirebaseQuiery.getRoomInfoList((roomInfoList) {
      this.roomInfoList = roomInfoList;
      isLoading = false;
      try {
        setState(() {});
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()))
        : roomInfoList.isEmpty
            ? const Center(
                child: Text("No Chat found"),
              )
            : ListView.builder(
                itemCount: roomInfoList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      String name =
                          roomInfoList[index].senderID == FirebaseAuth.instance.currentUser!.uid ? roomInfoList[index].receiverName : roomInfoList[index].senderName;
                      String itemUserID =
                          roomInfoList[index].senderID == FirebaseAuth.instance.currentUser!.uid ? roomInfoList[index].receiverID : roomInfoList[index].senderID;

                      UserInfoDetails userInfoDetails = UserInfoDetails(email: "", password: "", name: name, uID: itemUserID);

                      Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDetailsScreen(senderDetails: userInfoDetails)));


                    },
                    child: ChatListItem(
                      title: roomInfoList[index].senderID == FirebaseAuth.instance.currentUser!.uid ? roomInfoList[index].receiverName : roomInfoList[index].senderName,
                      subTile: roomInfoList[index].lastMessage,
                      unReadMessage: roomInfoList[index].senderID == FirebaseAuth.instance.currentUser!.uid ? 0 : roomInfoList[index].unReadMessage,
                    ),
                  );
                },
              );
  }
}
