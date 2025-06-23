///😍😍😍😍😍😍😍😍😍😍😍😍😍

import 'package:near_me_new_version/core/data/models/notification.dart';

abstract class NotificationEvent {}

class SaveNotification extends NotificationEvent {
  final Notifications notification;

  SaveNotification({required this.notification});
}

// class LoadNotifications extends NotificationEvent {
//   final String userId;
//  // final String? groupId;
//   LoadNotifications(this.userId);
// }

class LoadGroupNotifications extends NotificationEvent {
  final String groupId;

   LoadGroupNotifications({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}
class LoadNotifications extends NotificationEvent {
  final String userId;
  final String groupId;

  LoadNotifications({required this.userId, this.groupId = ''});

  @override
  List<Object> get props => [userId, groupId];
}

class LoadUserGroupNotifications extends NotificationEvent {
  final String userId;
  final String groupId;

  LoadUserGroupNotifications({required this.userId, required this.groupId});

  @override
  List<Object> get props => [userId, groupId];
}
