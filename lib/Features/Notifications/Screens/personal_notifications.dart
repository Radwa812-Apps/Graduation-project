import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import '../../../core/constants.dart';
import '../Components/personal_notification.dart';

class PersonalNotifications extends StatelessWidget {
  final String title;
  static const personalNotificationsKey = '/PersonalNotifications';

  const PersonalNotifications({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Container(
          width: 393.w,
          height: 852.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: background,
          ),
          child: Column(
            children: [
              HeaderNotifications(
                title: title,
                onBackPressed: () {
                  Navigator.pop(context);
                }, image: "assets/images/user.jpg",
              ),
              const DateLabel(dateText: 'Yesterday'),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  children: [
                    PersonalNotificationItem(
                      message: 'Aliaa just arrived home',
                      time: '12:00 PM',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GroupNotifications(
                              title: 'Aliaa',
                            ),
                          ),
                        );
                      },
                      showForwardIcon: false,
                    ),
                    PersonalNotificationItem(
                      message: 'Aliaa on her way to work',
                      time: '12:00 PM',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GroupNotifications(
                              title: 'Aliaa',
                            ),
                          ),
                        );
                      },
                      showForwardIcon: false,
                    ),
                    PersonalNotificationItem(
                      message: 'Aliaa at the gym',
                      time: '12:00 PM',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GroupNotifications(
                              title: 'Aliaa',
                            ),
                          ),
                        );
                      },
                      showForwardIcon: false,
                    ),
                    PersonalNotificationItem(
                      message: 'Aliaa on her way to Home',
                      time: '12:00 PM',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GroupNotifications(
                              title: 'Aliaa',
                            ),
                          ),
                        );
                      },
                      showForwardIcon: false,
                    ),
                    PersonalNotificationItem(
                      message: 'Aliaa At El-Hamed Supermarket',
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
                      showForwardIcon: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
