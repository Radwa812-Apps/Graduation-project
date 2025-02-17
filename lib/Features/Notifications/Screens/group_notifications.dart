import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';
import 'package:near_me_new_version/Features/Notifications/Components/notification_item.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/personal_notifications.dart';
import '../../../core/constants.dart';
class GroupNotifications extends StatelessWidget {
  final String title;
  static const groupNotificationsKey = '/GroupNotifications';

  const GroupNotifications({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? groupName =
        ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: background,
          ),
          child: Column(
            children: [
              HeaderNotifications(
                title: groupName ?? title,
                onBackPressed: () {
                  Navigator.pop(context);
                },
                image: "assets/images/group.jpg",
              ),
              const DateLabel(dateText: 'Yesterday'),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      NotificationItem(
                        name: 'Aliaa',
                        message: 'Aliaa just arrived home',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalNotifications(
                                title: 'Aliaa',
                              ),
                            ),
                          );
                        },
                        showForwardIcon: true,
                      ),
                      NotificationItem(
                        name: 'Radwa',
                        message: 'Radwa just arrived home',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupNotifications(
                                title: 'Radwa',
                              ),
                            ),
                          );
                        },
                        showForwardIcon: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
