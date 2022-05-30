import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_application/model/message_model.dart';
import 'package:firebase_chat_application/model/onlineStatus.dart';
import 'package:firebase_chat_application/model/room_info.dart';
import 'package:firebase_chat_application/model/user_info.dart';
import 'package:firebase_chat_application/pref/pref_const.dart';
import 'package:timeago/timeago.dart' as timeago;

class FirebaseQuiery {
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static String? userID = FirebaseAuth.instance.currentUser!.uid;

  static late StreamSubscription<QuerySnapshot> event1;
  static late StreamSubscription<QuerySnapshot> event2;
  static late StreamSubscription<DocumentSnapshot> event3;

  static String myName = Pref.getValue("myName")!;

  static getUserList(Function(List<UserInfoDetails> userInfoDetailsList) userInfoDetailsListCallback) async {
    List<UserInfoDetails> userInfoDetailsList = [];

    await firebaseFirestore.collection("users").get().then((value) {
      for (var element in value.docs) {
        if (element.data()['uID'] != FirebaseAuth.instance.currentUser!.uid) {
          userInfoDetailsList
              .add(UserInfoDetails(password: element.data()['password'], email: element.data()['email'], name: element.data()['name'], uID: element.data()['uID']));
        }
      }
    });

    userInfoDetailsListCallback(userInfoDetailsList);
  }

  static getRoomInfoList(Function(List<RoomInfo> roomInfoList) roomInfoList) {
    List<RoomInfo> roomInfoListLocal = [];
    firebaseFirestore.collection("roomInfo").where("roomUsersID", arrayContains: FirebaseAuth.instance.currentUser!.uid).snapshots().listen((value) {
      log("Collection found ${value.docs.length}");

      roomInfoListLocal = [];
      for (var element in value.docs) {
        log("Collection found message type ${element.get("messageType")}");
        log("Collection found ${element.get("lastMessage")}");
        log("Collection found ${element.get('roomID')}");

        RoomInfo roomInfo = RoomInfo(
            uID: element.get("uID"),
            roomID: element.get('roomID'),
            lastMessage: element.get('lastMessage'),
            lastMessageID: element.get("lastMessageID"),
            senderID: element.get('senderID'),
            receiverID: element.get("receiverID"),
            messageType: element.get("messageType"),
            unReadMessage: element.get('unReadMessage'),
            senderName: element.get('senderName'),
            receiverName: element.get('receiverName'),
            senderImage: element.get('senderImage'),
            receiverImage: element.get('receiverImage'),
            createdAt: element.get('createdAt'),
            updatedAt: element.get('updatedAt'),
            deletedAt: element.get('deletedAt'),
            isDeleteMessage: element.get('isDeleteMessage'),
            roomUsersID: element.get('roomUsersID'));
        roomInfoListLocal.add(roomInfo);
      }
      roomInfoList(roomInfoListLocal);
    });
  }

  static sendMessage({required String messageString, required String receiverID, required String receiverName, RoomInfo? roomInfoObj, int messageType = 1}) {
    log("send message room info is = $roomInfoObj");

    if (roomInfoObj != null) {
      String messagesAutoID = firebaseFirestore.collection("messageRoom").doc(roomInfoObj.roomID).collection("messages").doc().id;

      RoomInfo roomInfo = RoomInfo(
          uID: userID!,
          roomID: roomInfoObj.roomID,
          lastMessage: messageString,
          lastMessageID: messagesAutoID,
          senderID: userID!,
          receiverID: receiverID,
          messageType: messageType,
          unReadMessage: roomInfoObj.senderID == userID ? roomInfoObj.unReadMessage + 1 : 1,
          senderName: myName,
          receiverName: receiverName,
          senderImage: roomInfoObj.senderImage,
          receiverImage: roomInfoObj.receiverImage,
          createdAt: roomInfoObj.createdAt,
          updatedAt: Timestamp.now(),
          deletedAt: roomInfoObj.deletedAt,
          isDeleteMessage: roomInfoObj.isDeleteMessage,
          roomUsersID: roomInfoObj.roomUsersID);

      log("messages sent 3");

      firebaseFirestore.collection("roomInfo").doc(roomInfo.roomID).update(roomInfo.toMap()).then((value) {
        createMessage(receiverName, receiverID, messageString, messagesAutoID, roomInfo.roomID,messageType);
      });
    } else {
      createNewChatInfo(messageString, receiverID, receiverName,messageType);
    }
  }

  static void createNewChatInfo(String messageString, String receiverID, String receiverName, int messageType) {
    String messageRoomAutoID = firebaseFirestore.collection("messageRoom").doc().id;
    String messagesAutoID = firebaseFirestore.collection("messageRoom").doc(messageRoomAutoID).collection("messages").doc().id;

    ///auto id messageRoom
    log("auto ID = $messageRoomAutoID");

    RoomInfo roomInfoSender = RoomInfo(
        uID: FirebaseAuth.instance.currentUser!.uid,
        roomID: messageRoomAutoID,
        lastMessage: messageString,
        lastMessageID: messagesAutoID,
        senderID: FirebaseAuth.instance.currentUser!.uid,
        messageType: messageType,
        unReadMessage: 1,
        senderName: myName,
        senderImage: "",
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        deletedAt: Timestamp.now(),
        isDeleteMessage: false,
        receiverID: receiverID,
        roomUsersID: [FirebaseAuth.instance.currentUser!.uid, receiverID],
        receiverImage: '',
        receiverName: receiverName);

    log("messages sent = 1");

    firebaseFirestore.collection("roomInfo").doc(messageRoomAutoID).set(roomInfoSender.toMap()).then((value) {
      createMessage(receiverName, receiverID, messageString, messagesAutoID, messageRoomAutoID,messageType);
    });
  }

  static void createMessage(String receiverName, String receiverID, String messageString, String messagesAutoID, String messageRoomAutoID, int messageType) {
    MessageModel messageModel = MessageModel(
        senderID: FirebaseAuth.instance.currentUser!.uid,
        receiverID: receiverID,
        userName: myName,
        roomId: messageRoomAutoID,
        messageText: messageString,
        messageType: messageType,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        deletedAt: Timestamp.now(),
        isDeleted: false,
        isSeenIs: false,
        image: "",
        video: "",
        audio: "",
        isSeenTime: Timestamp.now(),
        messageID: messagesAutoID);

    log("messages sent ${messageModel.toJson()}");
    firebaseFirestore.collection("messageRoom").doc(messageRoomAutoID).collection("messages").doc(messagesAutoID).set(messageModel.toJson());
  }

  static void getMyInformation(Function(UserInfoDetails userInfoDetails) userInfoDetails) {
    firebaseFirestore.collection("users").doc(userID).get().then((value) {
      log("message = ${UserInfoDetails(email: value.get('email'), password: value.get('password'), name: value.get('name'), uID: value.get("uID")).toMap()}");

      userInfoDetails(UserInfoDetails(email: value.get('email'), password: value.get('password'), name: value.get('name'), uID: value.get("uID")));
    });
  }

  static void getMessageHistory(String senderUID, Function(List<MessageModel> messageModelList) messageModel, Function(RoomInfo roomInfo) roomInfoBack) {
    RoomInfo roomInfoObj;

    try {
      event1 = firebaseFirestore.collection("roomInfo").where("roomUsersID", arrayContainsAny: [userID]).snapshots().listen((event) {
            log("doc is = ${event.docs.length}");
            if (event.docs.isNotEmpty) {
              log("doc is 2= ${event.docs.length}");
              bool firstChat = true;
              late List<MessageModel> messageModelListLocal;

              for (var element in event.docs) {
                RoomInfo roomInfo = RoomInfo(
                    uID: ('uID'),
                    roomID: element.get('roomID'),
                    lastMessage: element.get('lastMessage'),
                    lastMessageID: element.get('lastMessageID'),
                    senderID: element.get('senderID'),
                    receiverID: element.get('receiverID'),
                    messageType: element.get('messageType'),
                    unReadMessage: element.get('unReadMessage'),
                    senderName: element.get('senderName'),
                    receiverName: element.get('receiverName'),
                    senderImage: element.get('senderImage'),
                    receiverImage: element.get('receiverImage'),
                    createdAt: element.get('createdAt'),
                    updatedAt: element.get('updatedAt'),
                    deletedAt: element.get('deletedAt'),
                    isDeleteMessage: element.get('isDeleteMessage'),
                    roomUsersID: element.get('roomUsersID'));

                if (roomInfo.roomUsersID.contains(senderUID) && roomInfo.roomUsersID.contains(userID)) {
                  roomInfoObj = roomInfo;
                  firstChat = false;
                  try {
                    event2 = firebaseFirestore
                        .collection("messageRoom")
                        .doc(roomInfo.roomID)
                        .collection("messages")
                        .orderBy("createdAt", descending: false)
                        .snapshots()
                        .listen((event) async {
                      messageModelListLocal = [];
                      for (var element in event.docs) {
                        messageModelListLocal.add(MessageModel(
                            senderID: element.get('userId'),
                            receiverID: element.get('receiverID'),
                            userName: element.get('userName'),
                            roomId: element.get('roomId'),
                            messageText: element.get('messageText'),
                            messageType: element.get('messageType'),
                            createdAt: element.get('createdAt'),
                            updatedAt: element.get('updatedAt'),
                            deletedAt: element.get('deletedAt'),
                            isDeleted: element.get('isDeleted'),
                            isSeenIs: element.get('isSeenIs'),
                            image: element.get('image'),
                            video: element.get('video'),
                            audio: element.get('audio'),
                            isSeenTime: element.get('isSeenTime'),
                            messageID: element.get('messageID'),
                            loadingStatus: false));
                      }

                      messageModel(messageModelListLocal);
                      roomInfoBack(roomInfoObj);

                      for (var element in messageModelListLocal) {
                        if (element.senderID != userID) {
                          if (!element.isSeenIs) {
                            log("call seen message ${element.senderID} and my id $userID");

                            if (Pref.getValue("callData") == "1") {
                              callSeenMessageUpdate(element.roomId, element.messageID, element.senderID);
                            } else {
                              log("Cancell call database");
                            }
                          }
                        }
                      }
                    });
                  } catch (e) {
                    log("event 2 error = $e");
                  }
                }
              }

              if (firstChat) {
                messageModel([]);
              }
            } else {
              messageModel([]);
            }
          });
    } catch (e) {
      log("event 1 error = $e");
    }
  }

  static onlineStatusGet(String uid, Function(OnlineStatus onlineStatus) onlineStatus) {
    log("last message ui id $uid");
    log("last message ui id $uid");

    event3 = firebaseFirestore.collection("onlineStatus").doc(uid).snapshots().listen((value) {
      if (value.exists) {
        log("last message ui time ${value.get('lastActiveAt')}");

        onlineStatus(OnlineStatus(
            createdAt: value.get('createdAt'),
            updatedAt: value.get('updatedAt'),
            lastActiveAt: value.get('lastActiveAt'),
            onlineStatus: value.get("onlineStatus"),
            uID: value.get("uID")));
      } else {
        log("last message ui time value is not exit");
        onlineStatus(OnlineStatus(createdAt: Timestamp.now(), updatedAt: Timestamp.now(), lastActiveAt: Timestamp.now(), onlineStatus: false, uID: uid));
      }
    });
  }

  static onlineStatusUpdate(bool onlineStatus) async {
    if(userID!=null){
      await firebaseFirestore.collection("onlineStatus").doc(userID).update({"updatedAt": Timestamp.now(), "lastActiveAt": Timestamp.now(), "onlineStatus": onlineStatus});
    }
  }

  static createOnlineStatus() {
    OnlineStatus onlineStatus = OnlineStatus(createdAt: Timestamp.now(), updatedAt: Timestamp.now(), lastActiveAt: Timestamp.now(), onlineStatus: true, uID: userID!);

    firebaseFirestore.collection("onlineStatus").doc(userID).get().then((value) {
      if (value.exists) {
      } else {
        firebaseFirestore.collection("onlineStatus").doc(userID).set(onlineStatus.toMap());
      }
    });
  }

  static callSeenMessageUpdate(String roomID, String messageID, String senderID) async {
    await firebaseFirestore.collection("messageRoom").doc(roomID).collection("messages").doc(messageID).update({"isSeenIs": true});
  }

  static callMessageCountUpdate(String roomID, String senderID) async {
    if (userID != senderID) {
      log("messages sent 2 $userID and $senderID");

      await firebaseFirestore.collection("roomInfo").doc(roomID).update({"unReadMessage": 0});
    }
  }

  static getTimeAgo(Timestamp dt) {
    return timeago.format(dt.toDate(), allowFromNow: true, locale: 'en_short');
  }
}
