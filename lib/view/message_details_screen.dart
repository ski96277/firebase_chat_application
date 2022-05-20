import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/firebaseQuery/firebase_quiery.dart';
import 'package:firebase_chat_application/model/message_model.dart';
import 'package:firebase_chat_application/model/onlineStatus.dart';
import 'package:firebase_chat_application/model/room_info.dart';
import 'package:firebase_chat_application/model/user_info.dart';
import 'package:firebase_chat_application/pref/pref_const.dart';
import 'package:flutter/material.dart';

class MessageDetailsScreen extends StatefulWidget {
  late UserInfoDetails senderDetails;

  MessageDetailsScreen({required this.senderDetails});

  @override
  State<MessageDetailsScreen> createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  TextEditingController messageController = TextEditingController();
  bool messageHistoryLoading = true;

  List<MessageModel> messageModelList = [];
  RoomInfo? roomInfo;

  OnlineStatus? onlineStatus;
  bool updateCall=false;

  @override
  void initState() {
    super.initState();
    Pref.setValue("callData", "1");
    FirebaseQuiery.getMessageHistory(widget.senderDetails.uID, (messageModelList) {
      this.messageModelList.clear();
      this.messageModelList = messageModelList;
      if (messageHistoryLoading) {
        messageHistoryLoading = false;
      }
      try {
        setState(() {});
      } catch (e) {}
      Future.delayed(const Duration(seconds: 1)).then((value) {
        _scrollDown();
      });
    }, (roomInfo) {
      this.roomInfo = roomInfo;

      if(!updateCall){
        updateCall=true;
        FirebaseQuiery.callMessageCountUpdate(roomInfo.roomID,roomInfo.senderID);

      }


    });
    FirebaseQuiery.onlineStatusGet(widget.senderDetails.uID, (onlineStatus) {
      this.onlineStatus = onlineStatus;
      setState((){});
    });
  }

  @override
  void dispose() {
    super.dispose();
    try {
      Pref.setValue("callData", "0");

      FirebaseQuiery.event1.pause();
      FirebaseQuiery.event2.pause();
      FirebaseQuiery.event3.pause();

      FirebaseQuiery.event1.cancel().then((value) {
        log("event1 cancel ");
      });
      FirebaseQuiery.event2.cancel().then((value) {
        log("event2 cancel");
      });
      FirebaseQuiery.event3.cancel().then((value) {
        log("event2 cancel");
      });
    } catch (e) {
      log("event cancel error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.senderDetails.name),
            onlineStatus != null
                ? onlineStatus!.onlineStatus
                    ? const Text(
                        "Active",
                        style: TextStyle(fontSize: 10),
                      )
                    : Text(
                        "Last seen ${FirebaseQuiery.getTimeAgo(onlineStatus!.lastActiveAt)=="now"?"1m":FirebaseQuiery.getTimeAgo(onlineStatus!.lastActiveAt)} ago",
                        style: const TextStyle(fontSize: 10),
                      )
                : const Text(
                    "Loading",
                    style: TextStyle(fontSize: 10),
                  ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[350],
        margin: const EdgeInsets.only(bottom: 80),
        child: Padding(
            padding: const EdgeInsets.only(
              top: 15,
            ),
            child: messageHistoryLoading
                ? const Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator()))
                : messageModelList.isEmpty
                    ? const Center(
                        child: Text("No message Found"),
                      )
                    : ListView.builder(
                        controller: _controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatRoomItem(messageModelList, index);
                        },
                        shrinkWrap: true,
                        itemCount: messageModelList.length)),
      ),
      floatingActionButton: getBottom(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  final ScrollController _controller = ScrollController();

// This is what you're looking for!
  void _scrollDown() {
    try {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(microseconds: 1000),
        curve: Curves.fastOutSlowIn,
      );
    } catch (e) {}
  }

  getBottom() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 5),
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              controller: messageController,
              hintText: "Write your message",
            ),
          ),
          IconButton(
              onPressed: () {
                if (messageController.text.isNotEmpty) {
                  FirebaseQuiery.sendMessage(messageController.text, widget.senderDetails.uID,widget.senderDetails.name, roomInfo);
                  messageController.text = "";
                }
              },
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.lightBlue,
                size: 35,
              ))
        ],
      ),
    );
  }
}

class ChatRoomItem extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<MessageModel> messageModelList;
  int index;

  ChatRoomItem(this.messageModelList, this.index);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(5.0), child: getPersonalChat());
  }

  getPersonalChat() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: messageModelList[index].senderID == _firebaseAuth.currentUser!.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: messageModelList[index].senderID == _firebaseAuth.currentUser!.uid
                ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20))
                : const BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: messageModelList[index].messageText,
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    const TextSpan(text: "   "),
                    TextSpan(
                      text: FirebaseQuiery.getTimeAgo(messageModelList[index].createdAt),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                messageModelList[index].isSeenIs ? Icons.check_circle_rounded : Icons.check_circle,
                size: 12,
                color: messageModelList[index].isSeenIs ? Colors.green : Colors.grey,
              )
            ],
          ),
        )
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final bool validatedField;
  final bool readOnly;
  final bool obscureText;
  final Widget? leadingIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;

  const CustomTextField(
      {Key? key,
      this.onTap,
      this.onChanged,
      this.keyboardType,
      this.controller,
      this.hintText,
      this.labelText,
      this.readOnly = false,
      this.validatedField = true,
      this.errorText = 'Cannot be empty',
      this.leadingIcon,
      this.suffixIcon,
      this.obscureText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      onChanged: onChanged,
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: Theme.of(context).accentColor,
      readOnly: readOnly,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: leadingIcon != null ? leadingIcon : null,
        suffixIcon: suffixIcon != null ? suffixIcon : null,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
        labelText: labelText,
        errorText: validatedField ? null : errorText,
      ),
    );
  }
}