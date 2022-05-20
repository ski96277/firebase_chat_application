
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderID;
  final String receiverID;
  final String messageText;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp deletedAt;
  final bool isDeleted;
  final bool isSeenIs;
  final Timestamp isSeenTime;
  final String image;
  final String video;
  final String audio;
  final int messageType; ///1=text,2=image,3=video,4=audio

  final String userName;
  final String roomId;
  final String messageID;


  const MessageModel({
    required this.senderID,
    required this.receiverID,
    required this.userName,
    required this.roomId,
    required this.messageText,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.isDeleted,
    required this.isSeenIs,
    required this.image,
    required this.video,
    required this.audio,
    required this.isSeenTime,
    required this.messageID,
  });

  static MessageModel fromJson(Map<String, dynamic> json) => MessageModel(
    senderID: json['senderID'],
    receiverID: json['receiverID'],
    userName: json['userName'],
    roomId: json['roomId'],
    image: json['image'],
    messageText: json['messageText'],
    messageType: json['messageType'],
    createdAt: json['createdAt']?.toDate(),
    updatedAt: json['updatedAt']?.toDate(),
    deletedAt: json['deletedAt']?.toDate(),
    isDeleted: json['isDeleted'],
    isSeenIs: json['isSeenIs'],
    video: json['video'],
    audio: json['audio'],
    messageID: json['messageID'],
    isSeenTime: json['isSeenTime']?.toDate(),
  );

  Map<String, dynamic> toJson() => {
    'userId': senderID,
    'receiverID': receiverID,
    'userName': userName,
    'roomId': roomId,
    'messageText': messageText,
    'messageType': messageType,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deletedAt': deletedAt,
    'isDeleted': isDeleted,
    'isSeenIs': isSeenIs,
    'image': image,
    'video': video,
    'audio': audio,
    'messageID': messageID,
    'isSeenTime': isSeenTime,
  };
}