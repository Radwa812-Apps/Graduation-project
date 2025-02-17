import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../messages.dart';

void handleFirebaseAuthException(FirebaseAuthException e, BuildContext context) {
  switch (e.code) {
    case 'account-exists-with-different-credential':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Account exists with a different credential.',
      );
      break;
    case 'invalid-credential':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Invalid credential provided.',
      );
      break;
    case 'user-disabled':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'User account is disabled.',
      );
      break;
    case 'user-not-found':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'No user found.',
      );
      break;
    case 'wrong-password':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Incorrect password.',
      );
      break;
    case 'operation-not-allowed':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Operation not allowed.',
      );
      break;
    default:
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Authentication error: ${e.message}',
      );
  }
}

void handleFirebaseException(FirebaseException e, BuildContext context) {
  switch (e.code) {
    case 'permission-denied':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Permission denied. You do not have access to this resource.',
      );
      break;
    case 'unavailable':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Firebase service is currently unavailable. Please try again later.',
      );
      break;
    case 'network-request-failed':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Network error. Please check your internet connection.',
      );
      break;
    default:
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Firebase error: ${e.message}',
      );
  }
}

void handlePlatformException(PlatformException e, BuildContext context) {
  switch (e.code) {
    case 'network_error':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Network error. Please check your connection.',
      );
      break;
    case 'sign_in_canceled':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Sign-In canceled by user.',
      );
      break;
    case 'sign_in_failed':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Google Sign-In failed. Please try again.',
      );
      break;
    case 'sign_in_required':
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Sign-In required. Please log in.',
      );
      break;
    default:
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'An error occurred: ${e.message}',
      );
  }
}

void handleUnknownException(dynamic e, BuildContext context) {
  AppMessages().sendVerification(
    context,
    Colors.red.withOpacity(0.8),
    'An unknown error occurred. Please try again.',
  );
}