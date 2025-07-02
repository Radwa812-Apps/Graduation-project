import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_in_screen.dart';
import 'package:near_me_new_version/core/services/internet_connection.dart';
import '../messages.dart';

Future<void> sendPasswordResetEmail({
  required BuildContext context,
  required String emailController,
}) async {
  bool isConnected = await checkConnection();
  if (!isConnected) {
    AppMessages().sendVerification(
      context,
      Colors.red.withOpacity(0.8),
      'No internet connection. Please check your network.',
    );

    return;
  }

  try {
    final email = emailController.trim();

    if (email.isEmpty) {
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        'Please enter your email.',
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    AppMessages().sendVerification(
      context,
      Colors.green.withOpacity(0.8),
      'A password reset link has been sent to your email. Please check your inbox.',
    );
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushNamed(context, SignInScreen.signInScreenKey);
  } catch (e) {
    AppMessages().sendVerification(
      context,
      Colors.red.withOpacity(0.8),
      e.toString(),
    );
  }
}
