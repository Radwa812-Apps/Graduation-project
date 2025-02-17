import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Splash_page/Screens/after_splash.dart';
import 'package:near_me_new_version/Features/Splash_page/components/animation_controller.dart';
import 'package:near_me_new_version/Features/Splash_page/components/gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/mainScaffold.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const String splashPageKey = '/';

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late SplashAnimationController _splashAnimationController;
  late AnimationController _controller;
  late Animation<double> _translateYAnimation;

  @override
  void initState() {
    super.initState();

    _splashAnimationController = SplashAnimationController(
      this,
      _navigateToNextScreen,
    );
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _translateYAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _splashAnimationController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('KeppUserLogIn');

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        await currentUser.reload();
        currentUser = FirebaseAuth.instance.currentUser;
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          currentUser = null;
        }
      }
    }

    if (currentUser != null && rememberMe == true) {
      Navigator.pushReplacementNamed(context, MainScaffold.mainScaffoldKey);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeView()),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 60,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Image.asset(
              'assets/images/logo.png',
              width: 300,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 54.5,
            left: MediaQuery.of(context).size.width / 2 + 20,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    _translateYAnimation.value,
                  ),
                  child: Image.asset(
                    'assets/images/logo_name.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
