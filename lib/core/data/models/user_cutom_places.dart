import 'package:cloud_firestore/cloud_firestore.dart';

class UserCustomPlace {
  final String id;
  final String userId;
  final String customPlaceId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserCustomPlace({
    required this.id,
    required this.userId,
    required this.customPlaceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserCustomPlace.fromJson(Map<String, dynamic> json,String id) {
    return UserCustomPlace(
      id:  id,
      userId: json['userId'] as String,
      customPlaceId: json['customPlaceId'] as String,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }
}
