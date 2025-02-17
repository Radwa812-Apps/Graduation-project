import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/phone_number.dart';

class Validator {
  static String? validateEditNameField(String? fieldName, String? value) {
    if (value != null) {
      if (value.contains(' ')) {
        return "$fieldName should not contain any spaces.";
      }

      if (value.length > 50) {
        return "$fieldName must be at most 50 characters long.";
      }
    }

    return null;
  }

  static String? validateEmptyField(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required.";
    }

    if (value.contains(' ')) {
      return "$fieldName should not contain any spaces.";
    }

    if (value.length > 50) {
      return "$fieldName must be at most 50 characters long.";
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }

    if (!value.endsWith('@gmail.com')) {
      return "Only Gmail addresses are accepted.";
    }

    final emailRegexp = RegExp(r'^[\w-]{1,64}(?:\.[\w-]{1,64})*@gmail\.com$');
    if (!emailRegexp.hasMatch(value)) {
      return "Invalid email address.";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '''Password must be at least 8 characters long, 
with one uppercase letter, one number, and one special character''';
    }
    if (value.contains(' ')) {
      return 'Password should not contain spaces.';
    }

    if (value.length < 8) {
      return "Password must be at least 8 characters long.";
    }
    if (value.length > 20) {
      return "Password must be at most 20 characters long.";
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return "Password must contain at least one uppercase letter.";
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return "Password must contain at least one lowercase letter.";
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return "Password must contain at least one number.";
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "Password must contain at least one special character.";
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value.contains(' ')) {
      return 'Password should not contain spaces.';
    }
    if (value.length > 20) {
      return "Password must be at most 20 characters long.";
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhoneNumber(PhoneNumber? value) {
    if (value == null || value.number.isEmpty || value.number.length < 4) {
      return "Phone number is required.";
    }

    final cleanedNumber =
        value.completeNumber.replaceAll(RegExp(r'[^+0-9]'), '');

    return null;
  }

  static String? validateDateOfBirth(DateTime? dateOfBirth) {
    if (dateOfBirth == null) {
      return "Date of birth is required.";
    }
    final age = DateTime.now().year - dateOfBirth.year;
    if (age < 5) {
      return "You must be at least 5 years old.";
    }
    return null;
  }
}
