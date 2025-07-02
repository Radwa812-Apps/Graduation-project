

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/core/data/bloc/Notification/notifications_event.dart';
import 'package:near_me_new_version/core/data/bloc/Notification/notifications_state.dart';
import 'package:near_me_new_version/core/data/models/notification.dart';
import 'package:near_me_new_version/core/services/location_noti.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  final FirebaseFirestore _firestore;

  NotificationBloc({
    required this.repository,
    FirebaseFirestore? firestore, 
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       super(NotificationInitial()) {
    on<SaveNotification>(_onSaveNotification);
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUserGroupNotifications>(_onLoadUserGroupNotifications);
    on<LoadGroupNotifications>(_onLoadGroupNotifications);
  }

  Future<void> _onLoadGroupNotifications(
    LoadGroupNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await repository.getNotificationsByGroup(
        event.groupId,
      );
      if (notifications.isEmpty) {
        emit(NotificationEmpty());
      } else {
        emit(GroupNotificationsLoaded(notifications));
      }
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onSaveNotification(
    SaveNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      await repository.saveNotification(event.notification);
      emit(NotificationSaved());
      add(
        LoadNotifications(
          userId: event.notification.userLocationId,
          groupId: '',
        ),
      );
    } catch (e) {
      emit(NotificationError(message: 'Failed to save notification'));
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      if (event.groupId.isEmpty) {
        // Load user notifications if no groupId provided
        await emit.forEach<List<Notifications>>(
          repository.getUserNotifications(event.userId),
          onData: (notifications) {
            if (notifications.isEmpty) return NotificationEmpty();
            return NotificationLoaded(notifications);
          },
        );
        print('Loaded user notifications🥵🥵🥵🥵🥵🥵: ${event.userId}');
      } else {
        // Load group notifications
        final notifications = await _getGroupNotifications(event.groupId);
        print(
          'Loaded group notifications😄😄😄😄😄😄: ${notifications.length}',
        );
        if (notifications.isEmpty) {
          emit(NotificationEmpty());
        } else {
          emit(NotificationLoaded(notifications));
        }
      }
    } catch (e) {
      emit(
        NotificationError(
          message: 'Failed to load notifications: ${e.toString()}',
        ),
      );
    }
  }

  Future<List<Notifications>> _getGroupNotifications(String groupId) async {
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();

    if (!groupDoc.exists) {
      throw Exception('Group not found');
    }

    final members = List<String>.from(groupDoc.data()?['members'] ?? []);

    if (members.isEmpty) {
      return [];
    }

    final snapshot =
        await _firestore
            .collection('notifications')
            .where('userLocationId', whereIn: members)
            .orderBy('timeOfLocation', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => Notifications.fromFirestore(doc))
        .toList();
  }

  Future<void> _onLoadUserGroupNotifications(
    LoadUserGroupNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await repository.getCurrentUserGroupNotifications(
        groupId: event.groupId,
        userId: event.userId,
      );
      if (notifications.isEmpty) {
        emit(NotificationEmpty());
      } else {
        emit(NotificationLoaded(notifications));
      }
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<List<Notifications>> _getUserGroupNotifications(
    String username,
    String groupId,
  ) async {
    
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    if (!groupDoc.exists) {
      print('Group not found😥😥😥😥: $groupId');
      throw Exception('Group not found😥😥😥😥');
    }
    final members = List<String>.from(groupDoc.data()?['members'] ?? []);
    if (members.isEmpty) {
      print('Group has no members');
      return [];
    }

    String? targetUserId;
    for (final userId in members) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final userName = userData?['fName'] as String?;

        if (userName != null && userName == username) {
          targetUserId = userId;
          break; 
        }
      }
    }

    if (targetUserId == null) {
      print('User $username not found 😥😥😥😥in group members');
      return [];
    }

    print('Found user 😘😘😘$username with ID: $targetUserId');


    final snapshot =
        await _firestore
            .collection('notifications')
            .where('userLocationId', isEqualTo: targetUserId)
            .orderBy('timeOfLocation', descending: true)
            .get();

    print(
      'Notifications for 😘😘😘$username in group $groupId: ${snapshot.docs.length}',
    );

    return snapshot.docs
        .map((doc) => Notifications.fromFirestore(doc))
        .toList();
  }
}