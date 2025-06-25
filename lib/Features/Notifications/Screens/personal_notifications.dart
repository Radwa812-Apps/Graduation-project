// ///😍😍😍😍😍😍😍😍😍😍😍😍😍
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
// import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';
// import 'package:near_me_new_version/Features/Notifications/Components/notification_item.dart';
// import 'package:near_me_new_version/Features/Notifications/Components/personal_notification.dart';
// import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
// import 'package:near_me_new_version/core/constants.dart';

// class PersonalNotifications extends StatefulWidget {
//   final String groupId;
//   final String userId;
//   final String title;
//   static const personalNotificationsKey = '/PersonalNotifications';

//   const PersonalNotifications({
//     Key? key,
//     required this.groupId,
//     required this.userId,
//     required this.title,
//   }) : super(key: key);

//   @override
//   State<PersonalNotifications> createState() => _PersonalNotificationsState();
// }

// class _PersonalNotificationsState extends State<PersonalNotifications> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late Stream<QuerySnapshot> _notificationsStream =
//       Stream<QuerySnapshot>.empty();

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   Future<void> _loadNotifications() async {
//     try {
//       // Initialize notifications stream for specific user in specific group
//       _notificationsStream =
//           _firestore
//               .collection('notifications')
//               .where(
//                 'userLocationId',
//                 isEqualTo: widget.userId,
//               ) // Only this user's notifications
//               .where(
//                 'groupsID',
//                 arrayContains: widget.groupId,
//               ) // Only in this specific group
//               .orderBy('timeOfLocation', descending: true)
//               .snapshots();

//       setState(() {});
//     } catch (e) {
//       debugPrint('Error loading notifications: $e');
//       if (mounted) {
//         setState(() {
//           _notificationsStream = Stream<QuerySnapshot>.empty();
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       body: SingleChildScrollView(
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(40),
//             color: background,
//           ),
//           child: Column(
//             children: [
//               HeaderNotifications(
//                 title: widget.title,
//                 backArrow: null,
//                 showCircleAvatar: false,
//                 image: "assets/images/group.jpg",
//               ),
//               const DateLabel(dateText: 'Recent'),
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.w,
//                     vertical: 10.h,
//                   ),
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: _notificationsStream,
//                     builder: (context, snapshot) {
//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       final items = <Widget>[];
//                       for (final doc in snapshot.data!.docs) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         final messageData = jsonDecode(data['messageLocation']);

//                         items.add(_buildNotificationItem(data, messageData));
//                       }

//                       return ListView(
//                         padding: EdgeInsets.zero,
//                         shrinkWrap: true,
//                         physics: const BouncingScrollPhysics(),
//                         children: items,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationItem(
//     Map<String, dynamic> data,
//     Map<String, dynamic> messageData,
//   ) {
//     // return NotificationItem(
//     //   title: widget.title,
//     //   name: messageData['userName'] ?? 'User',
//     //   message:
//     //       '${messageData['userName']} ${messageData['eventType']?.toString().toLowerCase() ?? ''} ${messageData['geofenceName'] ?? ''}',
//     //   time: _formatTime(data['timeOfLocation']),
//     //   onPressed: null, // No navigation for personal notifications
//     //   showForwardIcon: false,
//     // );
//     return PersonalNotificationItem(
//       message:
//           '${messageData['userName']} ${messageData['eventType']?.toString().toLowerCase() ?? ''} ${messageData['geofenceName'] ?? ''}',
//       time: _formatNotificationTime(data['timeOfLocation']),
//       onPressed: null, // No navigation for personal notifications
//       showForwardIcon: false,
//     );
//   }

//   String _formatNotificationDate(Timestamp? timestamp) {
//     if (timestamp == null) return '';
//     final date = timestamp.toDate();
//     final today = DateTime.now();

//     if (date.year == today.year &&
//         date.month == today.month &&
//         date.day == today.day) {
//       return 'Today';
//     }

//     final yesterday = today.subtract(const Duration(days: 1));
//     if (date.year == yesterday.year &&
//         date.month == yesterday.month &&
//         date.day == yesterday.day) {
//       return 'Yesterday';
//     }

//     return DateFormat('MMMM d, y').format(date);
//   }

//   String _formatNotificationTime(Timestamp? timestamp) {
//     if (timestamp == null) return '';
//     return DateFormat('hh:mm a').format(timestamp.toDate());
//   }
// }


import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';
import 'package:near_me_new_version/Features/Notifications/Components/notification_item.dart';
import 'package:near_me_new_version/Features/Notifications/Components/personal_notification.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import 'package:near_me_new_version/core/constants.dart';

class PersonalNotifications extends StatefulWidget {
  final String groupId;
  final String userId;
  final String title;
  static const personalNotificationsKey = '/PersonalNotifications';

  const PersonalNotifications({
    Key? key,
    required this.groupId,
    required this.userId,
    required this.title,
  }) : super(key: key);

  @override
  State<PersonalNotifications> createState() => _PersonalNotificationsState();
}

class _PersonalNotificationsState extends State<PersonalNotifications> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _notificationsStream =
      Stream<QuerySnapshot>.empty();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      _notificationsStream =
          _firestore
              .collection('notifications')
              .where('userLocationId', isEqualTo: widget.userId)
              .where('groupsID', arrayContains: widget.groupId)
              .orderBy('timeOfLocation', descending: true)
              .snapshots();

      setState(() {});
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _notificationsStream = Stream<QuerySnapshot>.empty();
        });
      }
    }
  }

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
              HeaderNotifications(
                title: widget.title,
                backArrow: null,
                showCircleAvatar: false,
                image: "assets/images/group.jpg",
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _notificationsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No notifications'));
                      }

                      // Group notifications by date
                      final Map<String, List<DocumentSnapshot>> groupedNotifications = {};
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final yesterday = today.subtract(const Duration(days: 1));

                      for (final doc in snapshot.data!.docs) {
                        final timestamp = doc['timeOfLocation'] as Timestamp;
                        final date = timestamp.toDate();
                        final dateKey = _getDateKey(date, today, yesterday);

                        groupedNotifications.putIfAbsent(dateKey, () => []).add(doc);
                      }

                      // Build the list of widgets
                      final items = <Widget>[];
                      groupedNotifications.forEach((dateKey, docs) {
                        // Add date label
                        items.add(DateLabel(dateText: dateKey));
                        
                        // Add notifications for this date
                        for (final doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final messageData = jsonDecode(data['messageLocation']);
                          items.add(_buildNotificationItem(data, messageData));
                        }
                      });

                      return ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        children: items,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateKey(DateTime date, DateTime today, DateTime yesterday) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  Widget _buildNotificationItem(
    Map<String, dynamic> data,
    Map<String, dynamic> messageData,
  ) {
    return PersonalNotificationItem(
      message:
          '${messageData['userName']} ${messageData['eventType']?.toString().toLowerCase() ?? ''} ${messageData['geofenceName'] ?? ''}',
      time: _formatNotificationTime(data['timeOfLocation']),
      onPressed: null,
      showForwardIcon: false,
    );
  }

  String _formatNotificationTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }
}