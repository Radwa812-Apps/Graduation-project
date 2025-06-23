///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:near_me_new_version/core/data/models/notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<void> saveNotification(Notifications notification) async {
    await _firestore.collection('notifications').add({
      'userLocationId': notification.userLocationId,
      'type': notification.type,
      'messageLocation': notification.messageLocation,
      'timeOfLocation':
          notification.timeOfLocation ?? FieldValue.serverTimestamp(),
      'groupsID': notification.groupsID,
    });
  }

  // في NotificationRepository

  Future<List<Notifications>> getNotificationsByGroup(String groupId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('notifications')
              .where('groupsID', arrayContains: groupId)
              .orderBy('timeOfLocation', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Notifications.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load group notifications: $e');
    }
  }

  // في NotificationRepository
  // في NotificationRepository
  Future<List<Notifications>> getCurrentUserGroupNotifications({
    required String groupId,
    required String userId,
  }) async {
    try {
      // 1. تحقق من أن المستخدم عضو في المجموعة
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final members = List<String>.from(groupDoc.get('members') ?? []);
      if (!members.contains(userId)) {
        return []; // المستخدم ليس عضو في المجموعة
      }

      // 2. جلب الإشعارات الخاصة بالمجموعة والمستخدم
      final querySnapshot =
          await _firestore
              .collection('notifications')
              .where('groupsID', arrayContains: groupId)
              .where('userLocationId', isEqualTo: userId)
              .orderBy('timeOfLocation', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => Notifications.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load user group notifications: $e');
    }
  }

  // Stream<List<Notifications>> getUserNotifications(String userId) {
  //   return _firestore
  //       .collection('notifications')
  //       .where('userLocationId', isEqualTo: userId)
  //       .orderBy('timeOfLocation', descending: true)
  //       .snapshots()
  //       .map(
  //         (snapshot) =>
  //             snapshot.docs
  //                 .map(
  //                   (doc) => Notifications(
  //                     id: doc.id,
  //                     userLocationId: doc['userLocationId'],
  //                     type: doc['type'],
  //                     messageLocation: doc['messageLocation'],
  //                     timeOfLocation: (doc['timeOfLocation'] as Timestamp),
  //                   ),
  //                 )
  //                 .toList(),
  //       );
  // }

  Stream<List<Notifications>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userLocationId', isEqualTo: userId)
        // .orderBy('timeOfLocation', descending: true)
        .snapshots()
        .handleError((error) {
          print('Firestore Error: $error');
          throw error;
        })
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Notifications.fromFirestore(doc))
                  .toList(),
        );
  }

  // Stream<List> getGroupNotifications(String groupId) {
  //   return FirebaseFirestore.instance
  //       .collection('groups')
  //       .doc(groupId)
  //       .snapshots()
  //       .asyncMap((groupSnapshot) async {
  //         if (!groupSnapshot.exists) return [];

  //         // Get all members in the group
  //         final members = List<String>.from(
  //           groupSnapshot.data()!['members'] ?? [],
  //         );

  //         if (members.isEmpty) return [];

  //         // Get notifications for all members
  //         final notifications = <Notifications>[];
  //         for (final memberId in members) {
  //           final memberNotifications =
  //               await _firestore
  //                   .collection('notifications')
  //                   .where('userLocationId', isEqualTo: memberId)
  //                   .get();

  //           notifications.addAll(
  //             memberNotifications.docs
  //                 .map((doc) => Notifications.fromFirestore(doc))
  //                 .toList(),
  //           );
  //         }

  //         // Sort by timestamp if needed
  //         notifications.sort(
  //           (a, b) => b.timeOfLocation.compareTo(a.timeOfLocation),
  //         );

  //         return notifications;
  //       })
  //       .handleError((error) {
  //         print('Firestore Error: $error');
  //         throw error;
  //       });
  // }

  Stream<List<Notifications>> getGroupNotifications(String groupId) async* {
    // First get all members in the current group
    final groupDoc =
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final members = List<String>.from(groupDoc.data()?['members'] ?? []);

    if (members.isEmpty) {
      yield []; // Return empty list if no members
      return;
    }

    // Then listen for notifications from all group members
    yield* FirebaseFirestore.instance
        .collection('notifications')
        .where('userLocationId', whereIn: members)
        .orderBy('timeOfLocation', descending: true)
        .snapshots()
        .handleError((error) {
          print('Firestore Error: $error');
          throw error;
        })
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Notifications.fromFirestore(doc))
                  .toList(),
        );
  }
}
