import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:near_me_new_version/core/data/models/geofence_model.dart';
import '../data/models/custom_places.dart';

Future<void> deleteUser(String documentId) async {
  try {
    String? user = FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {
      return;
    }

    QuerySnapshot userCustomPlacesSnapshot =
        await FirebaseFirestore.instance
            .collection('user_customPlaces')
            .where('customPlaceId', isEqualTo: documentId)
            .where('userId', isEqualTo: user)
            .get();
    for (var doc in userCustomPlacesSnapshot.docs) {
      await FirebaseFirestore.instance
          .collection('user_customPlaces')
          .doc(doc.id)
          .delete();
      print("User Custom Place Deleted: ${doc.id}");
    }

    await FirebaseFirestore.instance
        .collection('customPlaces')
        .doc(documentId)
        .delete();
    print("User Deleted");
  } catch (error) {
    print("Failed to delete user: $error");
  }
}

Future<void> updateUser(String documentId, String newName) async {
  try {
    await FirebaseFirestore.instance
        .collection('customPlaces')
        .doc(documentId)
        .update({'name': newName});
    print("User Updated");
  } catch (error) {
    print("Failed to update user: $error");
  }
}

Future<List<GeofenceModel>> getUserGeofences() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final geofencesSnapshot =
      await FirebaseFirestore.instance
          .collection('userGeofences')
          .doc(userId)
          .collection('geofences')
          .orderBy('createdAt', descending: true)
          .get();

  return geofencesSnapshot.docs.map((doc) {
    final data = doc.data();
    return GeofenceModel(
      id: data['id'] ?? doc.id,
      location: LatLng(data['latitude'] ?? 0.0, data['longitude'] ?? 0.0),
      radiusMeters: data['radius'] ?? 100.0,
      placeName: data['placeName'] ?? 'No Name',
    );
  }).toList();
}
