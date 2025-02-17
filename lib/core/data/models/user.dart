import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/phone_number.dart';

class UserModel {
  final String id;
  final String fName;
  final String lName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String profilPicture;
  final String role;

  UserModel(
      {required this.id,
      required this.fName,
      required this.lName,
      required this.email,
      required this.phoneNumber,
      required this.dateOfBirth,
      required this.profilPicture,
      required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    //final String rawPhoneNumber = json['phoneNumber'];
    // final RegExp regex = RegExp(r'\s*(\d+)');
    // final match = regex.firstMatch(rawPhoneNumber);
    // final String phoneNumberString = match != null ? match.group(0)! : '';

    return UserModel(
      id: id,
      fName: json['fName'],
      lName: json['lName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'],
      profilPicture: json['profilPicture'],
      role: json['role'],
    );
  }

  factory UserModel.fromUserCredential({
    required UserCredential userCredential,
  }) {
    final user = userCredential.user;
    if (user == null) {
      throw Exception("UserCredential does not contain a valid user.");
    }
    return UserModel(
        id: user.uid,
        fName: user.displayName ?? '',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber ??
            'PhoneNumber(countryISOCode: EG, countryCode: +20, number: 1100338766)',
        dateOfBirth: '',
        profilPicture: user.photoURL ?? 'assets/images/user.jpg',
        role: 'not admin',
        lName: '');
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
    };
  }
}
