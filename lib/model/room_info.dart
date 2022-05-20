import 'package:cloud_firestore/cloud_firestore.dart';

class RoomInfo{
  String uID;
  String roomID;
  String lastMessage;
  String lastMessageID;
  String senderID;
  String receiverID;
  String senderName;
  String receiverName;
  String senderImage;
  String receiverImage;
  int messageType;
  int unReadMessage;
  Timestamp createdAt;
  Timestamp updatedAt;
  Timestamp deletedAt;
  bool isDeleteMessage;
  List<dynamic> roomUsersID;

  RoomInfo(
      {required this.uID,
      required this.roomID,
      required this.lastMessage,
      required this.lastMessageID,
      required this.senderID,
      required this.receiverID,
      required this.messageType,
      required this.unReadMessage,
      required this.senderName,
      required this.receiverName,
      required this.senderImage,
      required this.receiverImage,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.isDeleteMessage,
      required this.roomUsersID});


  Map<String, dynamic> toMap() {
    return {
      'uID': uID,
      'roomID': roomID,
      'lastMessage': lastMessage,
      'lastMessageID': lastMessageID,
      'senderID': senderID,
      'receiverID': receiverID,
      'messageType': messageType,
      'unReadMessage': unReadMessage,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderImage': senderImage,
      'receiverImage': receiverImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'isDeleteMessage': isDeleteMessage,
      'roomUsersID': roomUsersID,
    };
  }

}