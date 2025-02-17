
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String groupMemberId;
  final String messageContent;
  final String messageStatus;
  final String typingStatus;
  final String onlineStatus;
  final String messageType; // (chat , group)
  final Timestamp timestamp;

  ChatMessage(
      {required this.id,
      required this.groupMemberId,
      required this.messageContent,
      required this.messageStatus,
      required this.typingStatus,
      required this.onlineStatus,
      required this.messageType,
      required this.timestamp});
  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessage(
        id: id,
        groupMemberId: json['groupMemberId'],
        messageContent: json['messageContent'],
        messageStatus: json['messageStatus'],
        typingStatus: json['typingStatus'],
        onlineStatus: json['onlineStatus'],
        messageType: json['messageType'],
        timestamp: json['timestamp'] as Timestamp);
  }
}
