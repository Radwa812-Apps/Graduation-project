
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_inside.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'round_image_widget.dart';

class GroupStyle extends StatefulWidget {
  final String? groupName;
  final String? groupId;

  const GroupStyle({super.key, this.groupName, this.groupId});

  @override
  _GroupStyleState createState() => _GroupStyleState();
}

class _GroupStyleState extends State<GroupStyle> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isAlerted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
        // إعادة تعيين الـ Flag بعد الانتهاء
        if (_isAlerted) {
          FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.groupId)
              .update({'alert_triggered': false});
        }
      }
    });
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
    _colorAnimation = ColorTween(begin: Colors.white, end: Colors.red.withOpacity(0.3)).animate(_animationController);

    // استمع لتغييرات alert_triggered
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final triggered = snapshot.data()?['alert_triggered'] ?? false;
        if (triggered && !_isAlerted) {
          setState(() {
            _isAlerted = true;
            _animationController.forward();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double spaceWithRows = screenWidth * 0.07.w;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _isAlerted ? _colorAnimation.value : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 74, 72, 72).withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: screenWidth * .2.w,
          height: screenHeight * .09.h,
          child: Transform.scale(
            scale: _isAlerted ? _scaleAnimation.value : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            GroupInsideScreen.groupInsideScreenKey,
                            arguments: widget.groupId,
                          );
                        },
                        child: RoundImageWidget(
                          name: 'assets/images/group.jpg',
                          width: screenWidth * .14.w,
                          height: screenHeight * .07.h,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          widget.groupName ?? '',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: kFontRegular,
                            color: kFontColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            GroupNotifications.groupNotificationsKey,
                            arguments: widget.groupName,
                          );
                        },
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 30.sp,
                          color: kPrimaryColor1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}