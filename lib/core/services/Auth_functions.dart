

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
    firestore
        .collection('users')
        .doc(uid)
        .update({
          "status": isOnline ? "Active" : "offline",
          "lastSeen": FieldValue.serverTimestamp(),
        })
        .catchError((error) {
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
    bool isTracking = false, 
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No authenticated user found");
        return;
      }

      
      final String? fcmToken = await _getFcmToken();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'authUid': user.uid,
        'fName': fName,
        'lName': lName,
        'email': email,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth,
        'profilPicture': profilPicture,
        'role': role,
        'fcmToken': fcmToken, 
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isTracking': isTracking, 
      });

      print("✅ User profile created for ${user.uid}");
      _setupTokenRefresh(user.uid);
    } catch (error, stack) {
      print("❌ User creation failed: $error");
      await FirebaseCrashlytics.instance.recordError(error, stack);
    }
  }
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

Future<void> saveTrackingState(bool isTracking) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isTracking': isTracking,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    FirebaseCrashlytics.instance.recordError(
      e,
      StackTrace.current,
      reason: 'Failed to save tracking state',
    );
    rethrow;
  }
}

Future<bool> loadTrackingState() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return false;

  try {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!doc.exists) return false;

    final data = doc.data();
    if (data == null) return false;

    return data['isTracking'] as bool? ?? false;
  } catch (e) {
    FirebaseCrashlytics.instance.recordError(
      e,
      StackTrace.current,
      reason: 'Failed to load tracking state',
    );
    return false;
  }
}
