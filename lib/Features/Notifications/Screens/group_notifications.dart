///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:near_me_new_version/Features/Notifications/Components/group_noti_element.dart';
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
  late String? _groupName;
  late String _groupId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _groupName = args['groupName'];
      _groupId = args['groupId'];
    } else {
      _groupName = widget.title;
      _groupId = widget.groupId;
    }

    // Load notifications for the entire group
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
            const DateLabel(dateText: 'Recent Activities'),
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
    // Group notifications by date
    final Map<String, List<Notifications>> groupedNotifications = {};
    
    for (final notification in notifications) {
      final date = _formatNotificationDate(notification.timeOfLocation);
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }

    // Sort dates in descending order
    final sortedDates = groupedNotifications.keys.toList()
      ..sort((a, b) => b.compareTo(a));

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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...dateNotifications.map((notification) {
            //  final messageData = jsonDecode(notification.messageLocation ?? '{}');
              return GroupNotiElement(
                userId: notification.userLocationId ?? '',
                notificationContent:notification.messageLocation ?? '',
                notificationTime: _formatNotificationTime(notification.timeOfLocation),
                groupId: _groupId,
                // userName: messageData['userName'],
                // userAvatar: 'assets/images/default_avatar.png', // You can fetch actual avatar
              );
            }).toList(),
          ],
        );
      },
    );
  }

  String _formatNotificationDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
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