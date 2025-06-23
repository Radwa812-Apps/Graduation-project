///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:near_me_new_version/core/data/models/group_custom_places.dart';

// class GroupCustomPlaceService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Create a new GroupCustomPlace
//   Future<String> createGroupCustomPlace({
//     required String customPlaceId,
//     required String groupId,
//   }) async {
//     try {
//       final docRef = await _firestore.collection('groupCustomPlaces').add({
//         'customPlaceId': customPlaceId,
//         'groupId': groupId,
//         'assignedAt': FieldValue.serverTimestamp(),
//       });
//       return docRef.id;
//     } catch (e) {
//       throw Exception('Failed to create GroupCustomPlace: $e');
//     }
//   }

//   // Get all custom places for a specific group
//   Stream<List<GroupCustomPlace>> getGroupCustomPlaces(String groupId) {
//     return _firestore
//         .collection('groupCustomPlaces')
//         .where('groupId', isEqualTo: groupId)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => GroupCustomPlace.fromFirestore(doc))
//             .toList());
//   }

//   // Delete a GroupCustomPlace
//   Future<void> deleteGroupCustomPlace(String id) async {
//     await _firestore.collection('groupCustomPlaces').doc(id).delete();
//   }
// }

class GroupCustomPlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a custom place to a group
  Future<void> addCustomPlaceToGroup({
    required String customPlaceId,
    required String groupId,
  }) async {
    try {
      // Update the group's customPlacesIds array
      await _firestore.collection('groups').doc(groupId).update({
        'customPlacesIds': FieldValue.arrayUnion([customPlaceId]),
      });
    } catch (e) {
      throw Exception('Failed to add custom place to group: $e');
    }
  }

  // Remove a custom place from a group
  Future<void> removeCustomPlaceFromGroup({
    required String customPlaceId,
    required String groupId,
  }) async {
    try {
      // Update the group's customPlacesIds array
      await _firestore.collection('groups').doc(groupId).update({
        'customPlacesIds': FieldValue.arrayRemove([customPlaceId]),
      });
    } catch (e) {
      throw Exception('Failed to remove custom place from group: $e');
    }
  }

  // Get all custom places IDs for a specific group
  Future<List<String>> getGroupCustomPlacesIds(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      return List<String>.from(doc['customPlacesIds'] ?? []);
    } catch (e) {
      throw Exception('Failed to get group custom places: $e');
    }
  }
}
