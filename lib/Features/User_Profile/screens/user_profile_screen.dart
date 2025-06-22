import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants.dart';
import '../components/user_profile_all_info_widget.dart';

class UserProfileScreen extends StatefulWidget {
  static String userProfileScreenKey = '/UserProfileScreen';
  UserProfileScreen({super.key});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool showThreeDotsWidget = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 90),
            UserProfileAll_InfoWidget(
              spaceWithRows: 30,
              paddingTopContainer: 48.h,
              imagePositionTop: -20,
            ),
            SizedBox(height: 90)
          ],
        ),
      ),
    );
  }
}
