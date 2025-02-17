import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_in_screen.dart';
import '../../../../core/constants.dart';
import '../components/custom_back_button.dart' show CustomBackButton;

class SuccessPage extends StatefulWidget {
  @override
  _SuccessPageState createState() => _SuccessPageState();

  static const String successPageKey = '/SuccessPage';
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _imageSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    return SlideTransition(
                      position: _imageSlideAnimation,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Image.network(
                          'https://img.freepik.com/free-vector/confirmed-concept-illustration_114360-5400.jpg',
                          width: 350.w,
                          height: 350.h,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _textSlideAnimation,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'Your account successfully',
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'created!',
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Text(
                    'Welcome to Your Ultimate Tracking Solution: Your Account is Created! Start Exploring the Ease of Real-Time Location Sharing and Stay Connected with Your Group Seamlessly!',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10.h),
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
                      Navigator.pushNamed(
                          context, SignInScreen.signInScreenKey);
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomBackButton(
            ontap: (() {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, SignInScreen.signInScreenKey);
            }),
            icon: Icons.close,
          )
        ],
      ),
    );
  }
}
