
import 'package:cloud_firestore/cloud_firestore.dart';
class GroupCustomPlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addCustomPlaceToGroup({
    required String customPlaceId,
    required String groupId,
  }) async {
    try {
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
  Future<List<String>> getGroupCustomPlacesIds(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      return List<String>.from(doc['customPlacesIds'] ?? []);
    } catch (e) {
      throw Exception('Failed to get group custom places: $e');
    }
  }
}
