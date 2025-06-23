///😍😍😍😍😍😍😍😍😍😍😍😍😍

// States
import 'package:near_me_new_version/core/data/models/notification.dart';

abstract class NotificationState {}

class GroupNotificationsLoaded extends NotificationState {
  final List<Notifications> notifications;

   GroupNotificationsLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}
class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSaved extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Notifications> notifications;

  NotificationLoaded(this.notifications);
   @override
  List<Object> get props => [notifications];
}

class NotificationEmpty extends NotificationState {} 

class NotificationError extends NotificationState {
  final String message;

  NotificationError({required this.message});

  @override
  List<Object> get props => [message];
}
