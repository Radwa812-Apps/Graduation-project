import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';


Future<bool?> checkIfGroupHasLiveLocations(String groupId) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('live_locations')
            .get();

    if (snapshot.docs.isEmpty) {
      log('📡 No live locations found for this group.');
      return false;
      
    } else {
      log('📍 Live locations exist!');
      return true;
     
    }
  } catch (e) {
    log('🔥 Error checking live locations from firestore: $e');
  }
}
