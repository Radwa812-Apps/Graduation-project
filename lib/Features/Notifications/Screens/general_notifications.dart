// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
// import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';
// import 'package:near_me_new_version/Features/Notifications/Components/notification_item.dart';
// import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
// import '../../../core/constants.dart';

// class GeneralNotifications extends StatefulWidget {
//   final String title;
//   static const generalNotificationsKey = '/GeneralNotifications';

//   const GeneralNotifications({Key? key, required this.title}) : super(key: key);

//   @override
//   State<GeneralNotifications> createState() => _GeneralNotificationsState();
// }

// class _GeneralNotificationsState extends State<GeneralNotifications> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late Stream<QuerySnapshot> _notificationsStream =
//       Stream<QuerySnapshot>.empty();
//   final Map<String, String> _groupNamesCache = {};
//   List<String> _userGroups = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserGroups();
//   }

//   Future<void> _loadUserGroups() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       // Get groups where current user is a member
//       final groupsQuery =
//           await _firestore
//               .collection('groups')
//               .where('members', arrayContains: user.uid)
//               .get();

//       _userGroups = groupsQuery.docs.map((doc) => doc.id).toList();

//       // Initialize notifications stream after getting user groups
//       _notificationsStream =
//           _firestore
//               .collection('notifications')
//               .where('groupsID', arrayContainsAny: _userGroups)
//               .orderBy('timeOfLocation', descending: true)
//               .snapshots();

//       setState(() {});
//     } catch (e) {
//       debugPrint('Error loading user groups: $e');

//       if (mounted) {
//         setState(() {
//           _notificationsStream = Stream<QuerySnapshot>.empty();
//         });
//       }
//     }
//   }

//   Future<String> _getGroupName(String groupId) async {
//     if (groupId.isEmpty) return 'General';
//     if (_groupNamesCache.containsKey(groupId)) {
//       return _groupNamesCache[groupId]!;
//     }

//     try {
//       final doc = await _firestore.collection('groups').doc(groupId).get();
//       final groupName =
//           doc.exists ? doc.get('name') ?? 'Unknown Group' : 'Unknown Group';
//       _groupNamesCache[groupId] = groupName;
//       return groupName;
//     } catch (e) {
//       debugPrint('Error getting group name: $e');
//       return 'Unknown Group';
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
//               const HeaderNotifications(
//                 title: 'Notifications',
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

//                       // Filter notifications to only show those from user's groups
//                       final items = <Widget>[];
//                       for (final doc in snapshot.data!.docs) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         final messageData = jsonDecode(data['messageLocation']);
//                         final groups = List<String>.from(
//                           data['groupsID'] ?? [],
//                         );

//                         // Only show notifications from groups the user is in
//                         final userGroupsInNotification =
//                             groups
//                                 .where(
//                                   (groupId) => _userGroups.contains(groupId),
//                                 )
//                                 .toList();

//                         if (userGroupsInNotification.isEmpty) continue;

//                         for (final groupId in userGroupsInNotification) {
//                           items.add(
//                             FutureBuilder<String>(
//                               future: _getGroupName(groupId),
//                               builder: (context, groupSnapshot) {
//                                 return _buildNotificationItem(
//                                   data,
//                                   messageData,
//                                   groupId,
//                                   groupSnapshot.data ?? 'Loading...',
//                                 );
//                               },
//                             ),
//                           );
//                         }
//                       }

//                       if (items.isEmpty) {
//                         return const Center(
//                           child: Text('No notifications for your groups'),
//                         );
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
//     String groupId,
//     String groupName,
//   ) {
//     return NotificationItem(
//       title: groupName,
//       name: messageData['userName'] ?? 'User',
//       message:
//           '${messageData['userName']} ${messageData['eventType']?.toString().toLowerCase() ?? ''} ${messageData['geofenceName'] ?? ''}',
//       time: _formatNotificationTime(data['timeOfLocation']),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) =>
//                     GroupNotifications(title: groupName, groupId: groupId),
//           ),
//         );
//       },
//       showForwardIcon: true,
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
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import '../../../core/constants.dart';

class GeneralNotifications extends StatefulWidget {
  final String title;
  static const generalNotificationsKey = '/GeneralNotifications';

  const GeneralNotifications({Key? key, required this.title}) : super(key: key);

  @override
  State<GeneralNotifications> createState() => _GeneralNotificationsState();
}

class _GeneralNotificationsState extends State<GeneralNotifications> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _notificationsStream =
      Stream<QuerySnapshot>.empty();
  final Map<String, String> _groupNamesCache = {};
  List<String> _userGroups = [];

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  Future<void> _loadUserGroups() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final groupsQuery =
          await _firestore
              .collection('groups')
              .where('members', arrayContains: user.uid)
              .get();

      _userGroups = groupsQuery.docs.map((doc) => doc.id).toList();

      _notificationsStream =
          _firestore
              .collection('notifications')
              .where('groupsID', arrayContainsAny: _userGroups)
              .orderBy('timeOfLocation', descending: true)
              .snapshots();

      setState(() {});
    } catch (e) {
      debugPrint('Error loading user groups: $e');
      if (mounted) {
        setState(() {
          _notificationsStream = Stream<QuerySnapshot>.empty();
        });
      }
    }
  }

  Future<String> _getGroupName(String groupId) async {
    if (groupId.isEmpty) return 'General';
    if (_groupNamesCache.containsKey(groupId)) {
      return _groupNamesCache[groupId]!;
    }

    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      final groupName =
          doc.exists ? doc.get('name') ?? 'Unknown Group' : 'Unknown Group';
      _groupNamesCache[groupId] = groupName;
      return groupName;
    } catch (e) {
      debugPrint('Error getting group name: $e');
      return 'Unknown Group';
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
              const HeaderNotifications(
                title: 'Notifications',
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
                        return const Center(
                          child: Text('No notifications available'),
                        );
                      }

                      // Group notifications by date
                      final Map<String, List<Map<String, dynamic>>>
                      groupedNotifications = {};
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final yesterday = today.subtract(const Duration(days: 1));

                      for (final doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final timestamp = data['timeOfLocation'] as Timestamp?;
                        if (timestamp == null) continue;

                        final date = timestamp.toDate();
                        final dateKey = _getDateKey(date, today, yesterday);

                        if (!groupedNotifications.containsKey(dateKey)) {
                          groupedNotifications[dateKey] = [];
                        }

                        groupedNotifications[dateKey]!.add(data);
                      }

                      // Build the list of notifications grouped by date
                      final items = <Widget>[];
                      groupedNotifications.forEach((dateKey, notifications) {
                        // Add date label
                        items.add(DateLabel(dateText: dateKey));

                        // Add notifications for this date
                        for (final data in notifications) {
                          final messageData = jsonDecode(
                            data['messageLocation'],
                          );
                          final groups = List<String>.from(
                            data['groupsID'] ?? [],
                          );

                          for (final groupId in groups.where(
                            (g) => _userGroups.contains(g),
                          )) {
                            items.add(
                              FutureBuilder<String>(
                                future: _getGroupName(groupId),
                                builder: (context, groupSnapshot) {
                                  return _buildNotificationItem(
                                    data,
                                    messageData,
                                    groupId,
                                    groupSnapshot.data ?? 'Loading...',
                                  );
                                },
                              ),
                            );
                          }
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
    String groupId,
    String groupName,
  ) {
    return NotificationItem(
      title: groupName,
      name: messageData['userName'] ?? 'User',
      message:
          '${messageData['userName']} ${messageData['eventType']?.toString().toLowerCase() ?? ''} ${messageData['geofenceName'] ?? ''}',
      time: _formatNotificationTime(data['timeOfLocation']),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    GroupNotifications(title: groupName, groupId: groupId),
          ),
        );
      },
      showForwardIcon: true,
    );
  }

  String _formatNotificationTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }
}
