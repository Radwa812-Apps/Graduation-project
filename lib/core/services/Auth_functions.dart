import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_me_new_version/core/data/models/custom_places.dart';

class Services {
  CollectionReference customPlace =
      FirebaseFirestore.instance.collection('users');
  Future<void> addUser({
    required String fName,
    required String lName,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String profilPicture,
    required String role,
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No user logged in!");
        return;
      }

      String userId = user.uid;

      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      await usersCollection.doc(userId).set({
        'authUid': userId,
        'fName': fName,
        'lName': lName,
        'email': email,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth,
        'profilPicture': profilPicture,
        'role': role,
      });

      print("✅ User added successfully with ID: $userId");
    } catch (error) {
      print("❌ Failed to add user: $error");
    }
  }
  Future<void> deleteCustomPlace(String dId) {
    return customPlace
        .doc(dId)
        .delete()
        .then((value) => print("customPlace Deleted"))
        .catchError((error) => print("Failed to delete customPlace: $error"));
  }
  
  ShowCustomPlaceMethod(String userId) async {
    var customPlaces = await FirebaseFirestore.instance
        .collection('customPlaces')
        .where('userId', isEqualTo: userId);

    QuerySnapshot querySnapshot = await customPlaces.get();
    List<CustomPlace> customplacesList = [];
    querySnapshot.docs.forEach((doc) {
      customPlace.add(CustomPlace.fromJson(doc.data(), doc.id));
    });
    return customplacesList;
  }
}
