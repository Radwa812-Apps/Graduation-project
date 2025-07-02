
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomPlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  CustomPlace({
    required this.id,
    
    required this.name,
    required this.latitude,
    required this.longitude,
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
