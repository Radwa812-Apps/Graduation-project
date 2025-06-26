import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:location/location.dart';
import 'dart:developer';

import 'package:near_me_new_version/core/data/models/userRadwa.dart';
import 'package:near_me_new_version/core/services/live_location_services.dart'
    as _firebaseController;

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

  Future<bool?> checkIfGroupHasUserLiveLocations(String groupId) async {
    final user = await firebase_auth.FirebaseAuth.instance.currentUser;
    log(
      "checkIfGroupHasUserLiveLocations, user: ${user?.uid}, groupId: $groupId",
    );
    try {
      final docSnapshot =
          await _firestore
              .collection('groups')
              .doc(groupId)
              .collection('live_locations')
              .doc(user!.uid)
              .get();
      return docSnapshot.exists;
    } catch (e) {
      log("Error checking live locations: $e");
      return null;
    }
  }

  void stopAlertAnimation(String groupId) {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      log("No user logged in, cannot stop alert animation.");
      return;
    }
    log("Stopping alert animation for group: $groupId");
    FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('group_alerts')
        .doc(user!.uid)
        .update({'alert_triggered': false});
  }

  Future<void> updateLiveLocation(
    String groupId,
    firebase_auth.User? user,
    bool isEnabled,
    LocationData? currentLocation, [
    LocationData? sourceLocation,
  ]) async {
    log(
      "Updating live location for group: $groupId, user: ${user?.uid}, isEnabled: $isEnabled",
    );
    final hasLiveLocations = await this.checkIfGroupHasUserLiveLocations(
      groupId,
    );
    if (hasLiveLocations != null && hasLiveLocations) {
      if (isEnabled && user != null && currentLocation != null) {
        await createLiveLocationInstance(
          groupId,
          user,
          currentLocation,
          sourceLocation,
        );
      } else {
        await deleteLiveLocationFromFirestore(groupId, user);
      }
    }
  }

  Future<void> deleteLiveLocationFromFirestore(
    String groupId,
    firebase_auth.User? user,
  ) async {
    try {
      log("Deleting live location for group: $groupId, user: ${user?.uid}");
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

  Future<void> createLiveLocationInstance(
    String groupId,
    firebase_auth.User user,
    LocationData currentLocation,
    LocationData? sourceLocation,
  ) async {
    try {
      log(
        "Creating live location instance for group: $groupId, user: ${user.uid}",
      );
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
  }

  Stream<QuerySnapshot> getGroupLiveLocationsStream(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('live_locations')
        .snapshots();
  }
}
