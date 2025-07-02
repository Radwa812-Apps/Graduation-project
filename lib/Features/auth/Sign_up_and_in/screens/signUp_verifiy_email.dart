import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_in_screen.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/core/messages.dart';
import '../../../../core/services/Auth_functions.dart';
import '../../../../core/services/internet_connection.dart';
import 'add_user_success.dart';

class SignUpVerificationEmailPage extends StatefulWidget {
  static const String signUpVerificationEmailPageKey =
      '/SignUpVerificationEmailPage';

  final Services services;
  const SignUpVerificationEmailPage({Key? key, required this.services})
    : super(key: key);

  @override
  _SignUpVerificationEmailPageState createState() =>
      _SignUpVerificationEmailPageState();
}

class _SignUpVerificationEmailPageState
    extends State<SignUpVerificationEmailPage>
    with SingleTickerProviderStateMixin {
  bool isEmailVerified = false;
  bool canResentEmail = false;
  bool isConnected = true;
  Timer? timer;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      initializeVerificationProcess();
    }
  }

  Future<void> initializeVerificationProcess() async {
    bool isConnected = await checkConnection();
    if (!isConnected) {
      if (mounted) {
        AppMessages().sendVerification(
          context,
          Colors.red.withOpacity(0.8),
          'No internet connection. Please check your network.',
        );
      }
      return;
    }

    await sendVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkEmailVerified();
    });
  }

  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future checkEmailVerified() async {
    bool isConnected = await checkConnection();
    {
      if (!isConnected) {
        AppMessages().sendVerification(
          context,
          Colors.red.withOpacity(0.8),
          'No internet connection. Please check your network.',
        );
        return;
      }
    }

    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      AppMessages().sendVerification(
        context,
        Colors.green.withOpacity(0.8),
        'Congratulations\nYour account has been created! Verify email to continue.',
      );

      timer?.cancel();
      final Map<String, dynamic> arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final String email = arguments['email'] as String;
      final String dateOfBirth = arguments['dateOfBirth'] as String;
      final String phoneNumber = arguments['phoneNumber'] as String;

      final String fname = arguments['fname'] as String;
      final String lname = arguments['lname'] as String;
      final fcmToken = await FirebaseMessaging.instance.getToken();

      await widget.services.addUser(
        fName: fname,
        lName: lname,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        profilPicture: 'assets/images/user.jpg',
        role: 'Not admin',
        fcmToken: fcmToken ?? '',
        isTracking: false, 
      );
    }
  }

  Future sendVerification() async {
    bool isConnected = await checkConnection();
    {
      if (!isConnected) {
        
        AppMessages().sendVerification(
          context,
          Colors.red.withOpacity(0.8),
          'No internet connection. Please check your network.',
        );
        return;
      }
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      // ignore: use_build_context_synchronously
      AppMessages().sendVerification(
        context,
        Colors.orange.withOpacity(0.8),
        "We've sent a confirmation email to your registered email address. Please check your inbox to verify your account and get started!",
      );
      setState(() => canResentEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResentEmail = true);
    } catch (e) {
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.8),
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? SuccessPage()
        : Scaffold(
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
                            height: 350.h,
                            width: 350.w,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Verify your email address!',
                      style: TextStyle(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: const Text(
                        'A Verification email has been sent to your email ,  Please check your inbox to verify your account and get started!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 3,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSpecialColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: Size(double.infinity, 50.h),
                        ),
                        onPressed: () {
                          if (isConnected) {
                            canResentEmail ? sendVerification() : null;
                          } else {
                            AppMessages().sendVerification(
                              context,
                              Colors.red.withOpacity(0.8),
                              "No internet connection. Please check your network settings.",
                            );
                          }
                        },
                        child: Text(
                          'Resend Email',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomBackButton(
                ontap: () {
                  //  FirebaseAuth.instance.signOut();
                  Navigator.pushNamed(context, SignInScreen.signInScreenKey);
                },
                icon: Icons.close,
              ),
            ],
          ),
        );
  }
}
