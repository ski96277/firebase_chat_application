import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineStatus {
  Timestamp createdAt;
  Timestamp updatedAt;
  Timestamp lastActiveAt;
  bool onlineStatus;
  String uID;

  OnlineStatus({required this.createdAt, required this.updatedAt, required this.lastActiveAt, required this.onlineStatus, required this.uID});

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastActiveAt': lastActiveAt,
      'onlineStatus': onlineStatus,
      'uID': uID,
    };
  }
}
