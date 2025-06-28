///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:near_me_new_version/core/data/models/custom_places.dart';

class Services {
  CollectionReference customPlace = FirebaseFirestore.instance.collection(
    'users',
  );


void setUserOnlineStatus(bool isOnline) {
    
final uid = FirebaseAuth.instance.currentUser!.uid;
final firestore = FirebaseFirestore.instance;
  firestore.collection('users').doc(uid).update({
    "status": isOnline ? "Active" : "offline",
    "lastSeen": FieldValue.serverTimestamp(),
  }).catchError((error) {
    print("Failed to update user status: $error");
  });
}
  Future<void> addUser({
    required String fName,
    required String lName,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String profilPicture,
    required String role,
    required String fcmToken,
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No authenticated user found");
        return;
      }

      // 1. الحصول على FCM Token
      final String? fcmToken = await _getFcmToken();

      // 2. إنشاء مستند المستخدم
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'authUid': user.uid,
        'fName': fName,
        'lName': lName,
        'email': email,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth,
        'profilPicture': profilPicture,
        'role': role,
        'fcmToken': fcmToken, // تخزين التوكن
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("✅ User profile created for ${user.uid}");

      // 3. إعداد تحديث التوكن التلقائي
      _setupTokenRefresh(user.uid);
    } catch (error, stack) {
      print("❌ User creation failed: $error");
      await FirebaseCrashlytics.instance.recordError(error, stack);
    }
  }

  // دالة مساعدة للحصول على FCM Token
  Future<String?> _getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print("🦕🦕🦕🦕🦕🦕🦕🦕🦕Generated FCM Token: $token");
      return token;
    } catch (e) {
      print("🦕🦕🦕🦕🦕🦕🦕🦕🦕Failed to get FCM token: $e");
      return null;
    }
  }

  // متابعة تحديثات التوكن
  void _setupTokenRefresh(String userId) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'fcmToken': newToken, 'updatedAt': FieldValue.serverTimestamp()},
        );
        print("♻️ Updated FCM Token for $userId");
      } catch (e) {
        print("🦕🦕🦕🦕🦕🦕🦕🦕🦕Failed to update token: $e");
      }
    });
  }
  // Future<void> addUser({
  //   required String fName,
  //   required String lName,
  //   required String email,
  //   required String phoneNumber,
  //   required String dateOfBirth,
  //   required String profilPicture,
  //   required String role,
  // }) async {
  //   try {
  //     final User? user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       print("❌ No user logged in!");
  //       return;
  //     }

  //     String userId = user.uid;

  //     CollectionReference usersCollection =
  //         FirebaseFirestore.instance.collection('users');

  //     await usersCollection.doc(userId).set({
  //       'authUid': userId,
  //       'fName': fName,
  //       'lName': lName,
  //       'email': email,
  //       'phoneNumber': phoneNumber,
  //       'dateOfBirth': dateOfBirth,
  //       'profilPicture': profilPicture,
  //       'role': role,
  //     });

  //     print("✅ User added successfully with ID: $userId");
  //   } catch (error) {
  //     print("❌ Failed to add user: $error");
  //   }
  // }

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
      customPlace.add(
        CustomPlace.fromFirestore(doc.data() as DocumentSnapshot),
      );
    });
    return customplacesList;
  }
}
