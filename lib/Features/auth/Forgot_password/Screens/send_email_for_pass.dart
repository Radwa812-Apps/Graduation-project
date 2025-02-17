import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_in_screen.dart';

import '../../../../core/constants.dart';
import '../../../../core/messages.dart';
import '../../../../core/services/internet_connection.dart';
import '../../Sign_up_and_in/components/custom_back_button.dart';
class PasswordResetPage extends StatefulWidget {
  static const String passwordResetPageKey = '/PasswordResetPage';

  const PasswordResetPage({Key? key}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage>
    with SingleTickerProviderStateMixin {
  bool isConnected = true;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TextEditingController _emailController = TextEditingController();
  StreamSubscription<User?>? _authStateSubscription;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _redirectTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
                context, SignInScreen.signInScreenKey);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _authStateSubscription?.cancel(); 
    _redirectTimer?.cancel();
    super.dispose();
  }

  Future<void> sendPasswordResetEmail() async {
    bool isConnected = await checkConnection();
    if (!isConnected) {
      if (mounted) {
        AppMessages().sendVerification(context, Colors.red.withOpacity(0.8),
            'No internet connection. Please check your network.');
      }
      return;
    }

    try {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        AppMessages().sendVerification(
            context, Colors.red.withOpacity(0.8), 'Please enter your email.');
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        AppMessages().sendVerification(context, Colors.green.withOpacity(0.8),
            'A password reset link has been sent to your email. Please check your inbox.');
      }
    } catch (e) {
      if (mounted) {
        AppMessages().sendVerification(
            context, Colors.red.withOpacity(0.8), e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Image.network(
                        'https://img.freepik.com/free-vector/new-message-concept-illustration_114360-6007.jpg',
                        height: 350,
                        width: 350,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Reset your password',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Enter your email address and we will send you a link to reset your password.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSpecialColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: sendPasswordResetEmail,
                    child: const Text(
                      'Send Reset Link',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomBackButton(
            ontap: () {
              Navigator.pushNamed(context, SignInScreen.signInScreenKey);
            },
            icon: Icons.close,
          ),
        ],
      ),
    );
  }
}
