
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:near_me_new_version/Features/Notifications/Components/group_noti_element.dart';
import 'package:near_me_new_version/Features/Notifications/Components/notification_item.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/personal_notifications.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/core/data/bloc/Notification/notifications_bloc.dart';
import 'package:near_me_new_version/core/data/bloc/Notification/notifications_event.dart';
import 'package:near_me_new_version/core/data/bloc/Notification/notifications_state.dart';
import 'package:near_me_new_version/core/data/models/notification.dart';
import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';

class GroupNotifications extends StatefulWidget {
  final String title;
  final String groupId;
  static const groupNotificationsKey = '/GroupNotifications';

  const GroupNotifications({
    Key? key,
    required this.title,
    required this.groupId,
  }) : super(key: key);

  @override
  _GroupNotificationsState createState() => _GroupNotificationsState();
}

class _GroupNotificationsState extends State<GroupNotifications> {
  late String _groupName;
  late String _groupId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _groupName = args['groupName'];
      _groupId = args['groupId'];
    } else {
      _groupName = widget.title;
      _groupId = widget.groupId;
    }

    context.read<NotificationBloc>().add(
      LoadGroupNotifications(groupId: _groupId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationError) {
            return Center(child: Text(state.message));
          } else if (state is NotificationEmpty) {
            return _buildEmptyState();
          } else if (state is GroupNotificationsLoaded) {
            return _buildContent(state.notifications);
          }

          return _buildContent([]);
        },
      ),
    );
  }

  Widget _buildContent(List<Notifications> notifications) {
    return SingleChildScrollView(
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
              title: _groupName ?? widget.title,
              onBackPressed: () => Navigator.pop(context),
              image: "assets/images/group.jpg",
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                child: _buildNotificationsList(notifications),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No group notifications yet', style: TextStyle(fontSize: 18.sp)),
          const SizedBox(height: 8),
          Text(
            'When group members check in, you\'ll see notifications here',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Notifications> notifications) {
    final Map<String, List<Notifications>> groupedNotifications = {};

    for (final notification in notifications) {
      final date = _formatNotificationGroupDate(notification.timeOfLocation);
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }

    // ترتيب التواريخ بشكل صحيح
    final sortedDates =
        groupedNotifications.keys.toList()..sort((a, b) {
          final dateA = _parseGroupDateToDateTime(a);
          final dateB = _parseGroupDateToDateTime(b);
          return dateB.compareTo(dateA); // الأحدث أولاً
        });

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateNotifications = groupedNotifications[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: DateLabel(dateText: date),
              ),
            ),
            ...dateNotifications.map((notification) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: NotificationItem(
                  name: _getUserName(notification.userLocationId),
                  message: notification.messageLocation ?? '',
                  time: _formatNotificationTime(notification.timeOfLocation),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PersonalNotifications(
                              groupId: _groupId,
                              userId: notification.userLocationId,
                              title: _groupName ?? widget.title,
                            ),
                      ),
                    );
                  },
                  showForwardIcon: true,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // دالة مساعدة لتحويل تاريخ المجموعة إلى DateTime
  DateTime _parseGroupDateToDateTime(String groupDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (groupDate == 'Today') {
      return today;
    } else if (groupDate == 'Yesterday') {
      return yesterday;
    } else {
      try {
        return DateFormat('MMMM d, y').parse(groupDate);
      } catch (e) {
        return DateTime(1970); // تاريخ افتراضي في حالة الخطأ
      }
    }
  }

  String _getUserName(String? userId) {
    // Implement logic to get user name from userId
    // You might want to fetch this from your user repository
    return userId ?? 'Unknown User';
  }

  String _formatNotificationGroupDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    final date = timestamp.toDate();
    final today = DateTime.now();

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return DateFormat('MMMM d, y').format(date);
  }

  String _formatNotificationTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }
}
