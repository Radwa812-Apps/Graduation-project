
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

  Future<List<Notifications>> getCurrentUserGroupNotifications({
    required String groupId,
    required String userId,
  }) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        throw Exception('Group not found');
      }

      final members = List<String>.from(groupDoc.get('members') ?? []);
      if (!members.contains(userId)) {
        return []; 
      }
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
  Stream<List<Notifications>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userLocationId', isEqualTo: userId)
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
  Stream<List<Notifications>> getGroupNotifications(String groupId) async* {
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
      yield []; 
      return;
    }
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
