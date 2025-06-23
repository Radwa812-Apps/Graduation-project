///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupCustomPlace {
  final String id;
  final String customPlaceId;
  final String groupId;
  final Timestamp assignedAt;
  
  GroupCustomPlace({
    required this.id,
    required this.customPlaceId,
    required this.groupId,
    required this.assignedAt,
  });

  // Convert Firestore document to GroupCustomPlace object
  factory GroupCustomPlace.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupCustomPlace(
      id: doc.id,
      customPlaceId: data['customPlaceId'],
      groupId: data['groupId'],
      assignedAt: data['assignedAt'],
    );
  }

  // Convert object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customPlaceId': customPlaceId,
      'groupId': groupId,
      'assignedAt': assignedAt,
    };
  }
}