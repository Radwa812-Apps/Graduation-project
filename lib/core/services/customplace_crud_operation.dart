import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/custom_places.dart';
Future<void> deleteUser(String documentId) async {
  try {
    String? user = FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {
      
      return;
    }

    QuerySnapshot userCustomPlacesSnapshot = await FirebaseFirestore.instance
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

Future<List<CustomPlace>> getUserCustomPlaces() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return []; 
  final userCustomPlacesSnapshot = await FirebaseFirestore.instance
      .collection('user_customPlaces')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .get();

  final customPlaces =
      await Future.wait(userCustomPlacesSnapshot.docs.map((doc) async {
    final customPlaceId = doc['customPlaceId'];
    final customPlaceDoc = await FirebaseFirestore.instance
        .collection('customPlaces')
        .doc(customPlaceId)
        .get();

    if (customPlaceDoc.exists) {
      final data = customPlaceDoc.data();
      if (data != null) {
        return CustomPlace(
          id: customPlaceDoc.id,
          name: data['name'] ?? 'No Name',
          latitude: data['latitude'],
          longitude: data['longitude'],
        );
      }
    }
    return null;
  }));

  return customPlaces.whereType<CustomPlace>().toList();
}
