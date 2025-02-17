import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocation {
  final String id;
  final String userId;
  final String locationId;
  final Timestamp assignedAt;

  UserLocation(
      {required this.id,
      required this.userId,
      required this.locationId,
      required this.assignedAt});

  factory UserLocation.fromJson(Map<String, dynamic> json, String id) {
    return UserLocation(
        id: id,
        userId: json['userId'],
        locationId: json['locationId'],
        assignedAt: json['assignedAt'] as Timestamp);
  }
}
