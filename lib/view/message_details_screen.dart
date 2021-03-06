import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/firebaseQuery/firebase_quiery.dart';
import 'package:firebase_chat_application/model/message_model.dart';
import 'package:firebase_chat_application/model/onlineStatus.dart';
import 'package:firebase_chat_application/model/room_info.dart';
import 'package:firebase_chat_application/model/user_info.dart';
import 'package:firebase_chat_application/pref/pref_const.dart';
import 'package:firebase_chat_application/widget/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class MessageDetailsScreen extends StatefulWidget {
  late UserInfoDetails senderDetails;

  MessageDetailsScreen({required this.senderDetails});

  @override
  State<MessageDetailsScreen> createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  TextEditingController messageController = TextEditingController();
  bool messageHistoryLoading = true;
  late File imagePath;
  Reference storageReference = FirebaseStorage.instance.ref("gs://my-custom-bucket");

  List<MessageModel> messageModelList = [];
  RoomInfo? roomInfo;

  OnlineStatus? onlineStatus;
  bool updateCall = false;

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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.senderDetails.name),
            onlineStatus != null
                ? onlineStatus!.onlineStatus
                    ? const Text(
                        "Online",
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
        // color: Colors.grey[350],
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
          messageController.text.isEmpty
              ? IconButton(
                  onPressed: () async {
                    showModalBottomSheet<void>(
                      context: this.context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          color: Colors.green[200],
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);

                                    imagePath = await AppUtils.getImageFromGallery();
                                    log("imagepath from gallery = ${imagePath.path}");
                                    String fileName = basename(imagePath.path);
//local list update
                                    messageModelList.add(MessageModel(
                                        senderID: FirebaseAuth.instance.currentUser!.uid,
                                        receiverID:  widget.senderDetails.uID,
                                        userName: "",
                                        roomId: "",
                                        messageText: imagePath.path,
                                        messageType: 2,
                                        createdAt: Timestamp.now(),
                                        updatedAt: Timestamp.now(),
                                        deletedAt: Timestamp.now(),
                                        isDeleted: false,
                                        isSeenIs: false,
                                        image: "",
                                        video: "",
                                        audio: "",
                                        isSeenTime: Timestamp.now(),
                                        messageID: "",
                                        loadingStatus: true));
                                    setState((){});
                                    // local list update end

                                    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('images/' + fileName);
                                    UploadTask uploadTask = firebaseStorageRef.putFile(imagePath);
                                    var imageUrl = await (await uploadTask).ref.getDownloadURL();

                                    log("imagepath from gallery = ${imageUrl}");

                                    FirebaseQuiery.sendMessage(
                                        messageString: imageUrl,
                                        receiverID: widget.senderDetails.uID,
                                        receiverName: widget.senderDetails.name,
                                        roomInfoObj: roomInfo,
                                        messageType: 2);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.camera,
                                        size: 34,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Gallery")
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 50,
                                ),
                                InkWell(
                                  onTap: () async {

                                    /*
                                    imagePath = await AppUtils.getImageFromCamera();
                                    log("imagepath from camera = ${imagePath.path}");
                                    Navigator.pop(context);

                                    String fileName = basename(imagePath.path);
                                    //local list update

                                    messageModelList.add(MessageModel(
                                        senderID: FirebaseAuth.instance.currentUser!.uid,
                                        receiverID:  widget.senderDetails.uID,
                                        userName: "",
                                        roomId: "",
                                        messageText: imagePath.path,
                                        messageType: 2,
                                        createdAt: Timestamp.now(),
                                        updatedAt: Timestamp.now(),
                                        deletedAt: Timestamp.now(),
                                        isDeleted: false,
                                        isSeenIs: false,
                                        image: "",
                                        video: "",
                                        audio: "",
                                        isSeenTime: Timestamp.now(),
                                        messageID: "",
                                        loadingStatus: true));
                                    setState((){});

                                    //local list update end

                                    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('images/' + fileName);
                                    UploadTask uploadTask = firebaseStorageRef.putFile(imagePath);
                                    var imageUrl = await (await uploadTask).ref.getDownloadURL();

                                    log("imagepath from camera = ${imageUrl}");

                                    FirebaseQuiery.sendMessage(
                                        messageString: imageUrl,
                                        receiverID: widget.senderDetails.uID,
                                        receiverName: widget.senderDetails.name,
                                        roomInfoObj: roomInfo,
                                        messageType: 2);*/

                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 34,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Camera")
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.lightBlue,
                    size: 25,
                  ))
              : const SizedBox(),
          IconButton(
              onPressed: () {
                if (messageController.text.isNotEmpty) {

                  //local text list update
                  messageModelList.add(MessageModel(
                      senderID: FirebaseAuth.instance.currentUser!.uid,
                      receiverID:  widget.senderDetails.uID,
                      userName: "",
                      roomId: "",
                      messageText: messageController.text,
                      messageType: 1,
                      createdAt: Timestamp.now(),
                      updatedAt: Timestamp.now(),
                      deletedAt: Timestamp.now(),
                      isDeleted: false,
                      isSeenIs: false,
                      image: "",
                      video: "",
                      audio: "",
                      isSeenTime: Timestamp.now(),
                      messageID: "",
                      loadingStatus: true));
                  setState((){});
                  // local test list update end

                  FirebaseQuiery.sendMessage(
                      messageString: messageController.text,
                      receiverID: widget.senderDetails.uID,
                      receiverName: widget.senderDetails.name,
                      roomInfoObj: roomInfo,
                      messageType: 1);
                  messageController.text = "";
                }
              },
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.lightBlue,
                size: 30,
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
    return Padding(padding: const EdgeInsets.all(5.0), child: getPersonalChat(context));
  }

  getPersonalChat(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: messageModelList[index].senderID == _firebaseAuth.currentUser!.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey[350],
            borderRadius: messageModelList[index].senderID == _firebaseAuth.currentUser!.uid
                ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20))
                : const BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              messageModelList[index].messageType == 1
                  ? Text(
                      messageModelList[index].messageText + " ",
                      maxLines: 10,
                      style: const TextStyle(fontSize: 15, color: Colors.black, overflow: TextOverflow.ellipsis),
                    )
                  : messageModelList[index].messageType == 2
                      ? InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FunkyOverlay(messageModelList[index].messageText)));

                          },
                          child:ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FadeInImage.assetNetwork(
                              placeholder: "assets/icon/image_loader_icon.png",
                              imageErrorBuilder: (context, error, stackTrace) {
                                return messageModelList[index].loadingStatus?Image.file(File(messageModelList[index].messageText),width: 200,height: 200,fit: BoxFit.cover,): Image.asset(
                                  "assets/icon/image_load_error.png",
                                  fit: BoxFit.cover,
                                  height: 50.0,
                                  width: 50,
                                );
                              },
                              fit: BoxFit.cover,
                              height: 200,
                              width: 200,
                              image: messageModelList[index].messageText,
                            ),
                          ),
                        )
                      : const SizedBox(),
              messageModelList[index].loadingStatus?const SizedBox(width:8,height: 8,child: CircularProgressIndicator(strokeWidth: 1,color: Colors.grey,)):Text(
                FirebaseQuiery.getTimeAgo(messageModelList[index].createdAt),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              messageModelList[index].senderID == _firebaseAuth.currentUser!.uid
                  ?messageModelList[index].loadingStatus?const SizedBox(): Icon(
                      messageModelList[index].isSeenIs ? Icons.check_circle_rounded : Icons.check_circle,
                      size: 12,
                      color: messageModelList[index].isSeenIs ? Colors.green : Colors.grey,
                    )
                  : const SizedBox()
            ],
          ),
        )
      ],
    );
  }
}

class FunkyOverlay extends StatefulWidget {
  String imageUrl;

  FunkyOverlay(this.imageUrl);

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.height,
          decoration: ShapeDecoration(color: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.0))),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FadeInImage.assetNetwork(
              placeholder: "assets/icon/profile.png",
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/icon/profile.png",
                  fit: BoxFit.cover,
                  height: 50.0,
                  width: 50,
                );
              },
              fit: BoxFit.contain,
              height: 200,
              width: 200,
              image: widget.imageUrl,
            ),
          ),
        ),
      ),
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
        prefixIcon: leadingIcon,
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        labelText: labelText,
        errorText: validatedField ? null : errorText,
      ),
    );
  }
}
