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

  factory GroupCustomPlace.fromJson(Map<String, dynamic> json, String id) {
    return GroupCustomPlace(
      id: id,
      customPlaceId: json['customPlaceId'] as String,
      groupId: json['groupId'] as String,
      assignedAt: json['assignedAt'] as Timestamp,
    );
  }
}
