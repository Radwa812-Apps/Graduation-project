
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class UserModel {
  final String id;
  final String fName;
  final String lName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String profilPicture;
  final String role;
  final List<String> groups;
  final String fcmToken;
  final bool isTracking;

  UserModel({
    required this.id,
    required this.fName,
    required this.lName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.profilPicture,
    required this.role,
    this.groups = const [],
    required this.fcmToken,
    this.isTracking = false, 
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      fName: json['fName'],
      lName: json['lName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      profilPicture: json['profilPicture'],
      role: json['role'],
      groups: List<String>.from(json['groups'] ?? []),
      fcmToken: json['fcmToken'] ?? '',
      isTracking: json['isTracking'] ?? false, 

    );
  }

  static Future<UserModel> fromUserCredential({
    required UserCredential userCredential,
  }) async {
    final user = userCredential.user;
    if (user == null) {
      throw Exception("UserCredential does not contain a valid user.");
    }
    final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';

    return UserModel(
      id: user.uid,
      fName: user.displayName ?? '',
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ??
          'PhoneNumber(countryISOCode: EG, countryCode: +20, number: 1100338766)',
      dateOfBirth: '',
      profilPicture: user.photoURL ?? 'assets/images/user.jpg',
      role: 'not admin',
      lName: '',
      groups: const [],
      fcmToken: fcmToken,
      isTracking: false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authUid': this.id,
      'fName': this.fName,
      'lName': this.lName,
      'email': this.email,
      'phoneNumber': this.phoneNumber,
      'dateOfBirth': this.dateOfBirth,
      'role': this.role,
      'profilPicture': this.profilPicture,
      'groups': this.groups,
      'fcmToken': this.fcmToken,
      'isTracking': this.isTracking, 
    };
  }
}