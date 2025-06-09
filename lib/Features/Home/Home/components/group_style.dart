import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import 'package:near_me_new_version/Features/share_location/screens/live_location_map.dart';
import '../../../../core/constants.dart';
import '../../../group_profile/screens/group_inside.dart';
import 'round_image_widget.dart';

class GroupStyle extends StatelessWidget {
  final String? groupName;
  final String? groupId; 

  const GroupStyle({super.key, this.groupName, this.groupId});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double spaceWithRows = screenWidth * 0.07.w;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: (() {
                    Navigator.pushNamed(
                      context,
                      OrderTrackingPage.OrderTrackingScreenKey,
                      arguments: groupId, 
                    );
                  }),
                  child: RoundImageWidget(
                    name: 'assets/images/group.jpg',
                    width: screenWidth * .14.w,
                    height: screenHeight * .07.h,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    groupName ?? '',
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
                  onPressed: (() {
                    Navigator.pushNamed(
                      context,
                      GroupNotifications.groupNotificationsKey,
                      arguments: groupName,
                    );
                  }),
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
    );
  }
}