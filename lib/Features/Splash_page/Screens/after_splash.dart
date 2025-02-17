import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_in_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../components/after_splash_pages.dart';
import '../controller/pages_controller.dart';
class WelcomeView extends StatelessWidget {
  WelcomeView({super.key});
  static String welcomeViewKey = '/WelcomeView';

  final OnBoardingController contoller = OnBoardingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        LiquidSwipe(
          onPageChangeCallback: contoller.onPageChangeCallback,
          liquidController: contoller.controller,
          pages: const [
            PageBody(
              image: 'assets/images/page1.png',
              subtitle:
                  'Stay connected and informed with instant updates on your group’s movements',
              pageNum: 1,
              title: 'Real-Time Location Tracking',
              color: Color.fromARGB(255, 231, 224, 224),
            ),
            PageBody(
              image: 'assets/images/page2.png',
              subtitle:
                  'Get notified the moment your group arrives at key locations – school, work, or home.',
              pageNum: 2,
              title: 'Real-Time Alerts And Notifications',
              color: Color.fromARGB(255, 238, 225, 175),
            ),
            PageBody(
              image: 'assets/images/page3.jpg',
              subtitle:
                  'Chat, coordinate, and stay updated with your group in real-time.',
              pageNum: 3,
              title: 'Seamless Group Communication',
              color: Colors.white,
            ),
          ],
          slideIconWidget: const Icon(Icons.arrow_back_ios),
          enableSideReveal: true,
        ),
        Positioned(
          bottom: 60,
          left: MediaQuery.of(context).size.width * 0.42,
          child: OutlinedButton(
            onPressed: () {
              if (contoller.controller != null) {
                contoller.animateToNextSlid();
              }
            },
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                side: const BorderSide(color: Colors.grey)),
            child: const Icon(
              Icons.arrow_forward_ios_sharp,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: MediaQuery.of(context).size.width * 0.44,
          child: Obx(() => AnimatedSmoothIndicator(
                activeIndex: contoller.page.value,
                count: 3,
                effect: const SlideEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    dotColor: Colors.black,
                    activeDotColor: Color(0xffffc801)),
              )),
        ),
        Positioned(
          top: 30,
          right: 10,
          child: TextButton(
            onPressed: () {
              if (contoller.controller != null) {
                contoller.skip();
                Navigator.pushNamed(context, SignInScreen.signInScreenKey);
              }
            },
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 20, color: Color(0xff2c444e)),
            ),
          ),
        )
      ]),
    );
  }
}
