import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';
import 'package:near_me_new_version/Features/Notifications/Components/notification_item.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import '../../../core/constants.dart';
class GeneralNotifications extends StatelessWidget {
  final String title;
  static const generalNotificationsKey = '/GeneralNotifications';

  const GeneralNotifications({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              const HeaderNotifications(
                title: 'Notifications',
                backArrow: null,
                showCircleAvatar: false, image: "assets/images/group.jpg",
              ),
              const DateLabel(dateText: 'Yesterday'),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      NotificationItem(
                        title: 'Alex Trip',
                        name: 'Aliaa',
                        message: 'Aliaa just arrived home',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.pushNamed(context,
                              GroupNotifications.groupNotificationsKey);
                        },
                        showForwardIcon: true,
                      ),
                      NotificationItem(
                        title: 'Home',
                        name: 'Radwa',
                        message: 'Radwa on her way to work',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupNotifications(
                                title: 'Home',
                              ),
                            ),
                          );
                        },
                        showForwardIcon: true,
                      ),
                      NotificationItem(
                        title: 'Home',
                        name: 'Nada',
                        message: 'Nada at the gym',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupNotifications(
                                title: 'Home',
                              ),
                            ),
                          );
                        },
                        showForwardIcon: true,
                      ),
                      NotificationItem(
                        title: 'Home',
                        name: 'Amira',
                        message: 'Amira on her way to Home',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupNotifications(
                                title: 'Home',
                              ),
                            ),
                          );
                        },
                        showForwardIcon: true,
                      ),
                      NotificationItem(
                        title: 'Home',
                        name: 'Nada',
                        message: 'Nada At El-Hamed Supermarket',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupNotifications(
                                title: 'Home',
                              ),
                            ),
                          );
                        },
                        showForwardIcon: true,
                      ),
                      NotificationItem(
                        title: 'University',
                        name: 'Nada',
                        message: 'Nada At El-Hamed Supermarket',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupNotifications(
                                title: 'University',
                              ),
                            ),
                          );
                        },
                        showForwardIcon: true,
                      ),
                      NotificationItem(
                        title: 'Home',
                        name: 'Nada',
                        message: 'Nada At El-Hamed Supermarket',
                        time: '12:00 PM',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GroupNotifications(
                                title: 'Home',
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
      // Bottom Bar
    );
  }
}
