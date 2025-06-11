import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:location/location.dart';
import 'dart:developer';

class FirebaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool?> checkIfGroupHasLiveLocations(String groupId) async {
    try {
      final snapshot =
          await _firestore
              .collection('groups')
              .doc(groupId)
              .collection('live_locations')
              .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking live locations: $e");
      return null;
    }
  }

  Future<void> updateLiveLocation(
    String groupId,
    firebase_auth.User? user,
    bool isEnabled,
    LocationData? currentLocation, [
    LocationData? sourceLocation,
  ]) async {
    if (isEnabled && user != null && currentLocation != null) {
      try {
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('live_locations')
            .doc(user.uid)
            .set({
              'curLat': currentLocation.latitude,
              'curLng': currentLocation.longitude,
              'sourceLat': sourceLocation?.latitude,
              'sourceLng': sourceLocation?.longitude,
              'timestamp': FieldValue.serverTimestamp(),
            });
      } catch (e) {
        log("Error updating live location: $e");
      }
    } else {
      try {
        await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('live_locations')
            .doc(user?.uid)
            .delete();
      } catch (e) {
        log("Error deleting live location: $e");
      }
    }
  }

  Stream<QuerySnapshot> getGroupLiveLocationsStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('live_locations')
        .snapshots();
  }
}
