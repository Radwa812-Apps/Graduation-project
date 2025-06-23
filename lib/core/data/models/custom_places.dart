///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomPlace {
  final String id;
  // final String userId;
  final String name;
  final double latitude;
  final double longitude;
  // final double radius;
  // final String notificationType;

  CustomPlace({
    required this.id,
    // required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    // required this.radius,
    // required this.notificationType,
  });
  factory CustomPlace.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomPlace(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
    );
  }
}
