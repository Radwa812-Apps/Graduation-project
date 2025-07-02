  import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:near_me_new_version/core/data/models/notification.dart';
import 'package:near_me_new_version/core/services/handle_dublicate_noti.dart' show NotificationSentCache;
import 'package:near_me_new_version/core/services/location_noti.dart';
import 'package:near_me_new_version/core/services/send_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';


Future<bool> checkLocationPermissions( BuildContext context) async {
    var status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions required')),
        );
        return false;
      }
    }
    return true;
  }

  @pragma('vm:entry-point')
   Future<void> geofenceTriggered(GeofenceCallbackParams params) async {
    try {
      final eventName =
          params.event == GeofenceEvent.enter
              ? "just arrived"
              : (params.event == GeofenceEvent.exit ? "just left" : "DWELL");

      final geofenceId = params.geofences.first.id;
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      if (userId == null) {
        print('No authenticated user found');
        return;
      }
      final geofenceIdd = params.geofences.first.id;
      if (!NotificationSentCache.shouldSendNotification(
        userId,
        geofenceIdd,
        params.event,
      )) {
        print('🦕 Duplicate geofence event - skipping');
        return;
      }

      // Get user profile data
      String firstName = 'User';
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (userDoc.exists) {
          firstName = userDoc.get('fName') ?? 'User';
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Querying groups for geofence: $geofenceId');
      final groupsQuery =
          await FirebaseFirestore.instance
              .collection('groups')
              .where('geofenceIds', arrayContains: geofenceId)
              .get();

      print(
        '🦕🦕🦕🦕🦕🦕🦕🦕🦕Found ${groupsQuery.docs.length} matching groups',
      );

      final matchingGroupIds = groupsQuery.docs.map((doc) => doc.id).toList();
      final Set<String> allMembers = {};
      for (final groupDoc in groupsQuery.docs) {
        final members = List<String>.from(groupDoc['members'] ?? []);
        allMembers.addAll(members);
        print(
          '👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻👨🏾‍🤝‍👨🏻Group ${groupDoc.id} has ${members.length} members',
        );
      }

      allMembers.remove(userId);
      print('🦕Total recipients: ${allMembers.length}');

      final placeName = extractPlaceNameFromGeofenceId(geofenceId);
      final eventVerb =
          params.event == GeofenceEvent.enter
              ? "just arrived"
              : (params.event == GeofenceEvent.exit ? "just left" : "is in");
      final repository = NotificationRepository(
        firestore: FirebaseFirestore.instance,
      );

      final currentUserNotification = Notifications(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userLocationId: userId,
        type: 'geofence',
        messageLocation: jsonEncode({
          'userName': firstName,
          'eventType': eventName,
          'geofenceName': placeName,
          'latitude': params.location?.latitude,
          'longitude': params.location?.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'relatedGroups': matchingGroupIds,
        }),
        timeOfLocation: Timestamp.now(),
        groupsID: matchingGroupIds,
      );
      await repository.saveNotification(currentUserNotification);

      final notificationsPlugin = FlutterLocalNotificationsPlugin();
      await notificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      const androidDetails = AndroidNotificationDetails(
        'geofence_channel',
        'Geofence Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      final notificationTitle = firstName;
      final notificationBody = '$eventVerb $placeName';

      await notificationsPlugin.show(
        params.hashCode,
        notificationTitle,
        notificationBody,
        const NotificationDetails(android: androidDetails),
      );
      if (allMembers.isNotEmpty) {
        await sendPushNotifications(
          recipients: allMembers.toList(),
          title: notificationTitle,
          body: notificationBody,
        );
      }
    } catch (e) {
      print('Geofence processing error: $e');
    }
  }




   Future<void> sendPushNotifications({
    required List<String> recipients,
    required String title,
    required String body,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection');
        return;
      }
      // Remove duplicates
      final uniqueRecipients = recipients.toSet().toList();

      print(
        '🦕 Preparing to notify ${uniqueRecipients.length} unique recipients',
      );

      print('🦕 Preparing to notify ${recipients.length} recipients');

      // Get valid FCM tokens
      final tokens = await fetchValidFcmTokens(recipients);

      if (tokens.isEmpty) {
        print('🦕 No valid device tokens found');
        return;
      }
      const batchSize = 500;
      for (var i = 0; i < tokens.length; i += batchSize) {
        final batch = tokens.sublist(
          i,
          i + batchSize > tokens.length ? tokens.length : i + batchSize,
        );

        print(
          '🦕 Sending to batch ${i ~/ batchSize + 1} (${batch.length} devices)',
        );

        int attempts = 0;
        bool success = false;
        while (attempts < 3 && !success) {
          try {
            // Send to each token in the batch
            for (final token in batch) {
              await SendNotificationService.sendNotificationUsingApi(
                fcmToken: token,
                title: title,
                body: body,
                data: {
                  'type': 'geofence_update',
                  'event_timestamp': DateTime.now().toIso8601String(),
                },
              );
            }
            success = true;
          } catch (e) {
            attempts++;
            print('Attempt $attempts failed: $e');
            await Future.delayed(Duration(seconds: 2));
          }
        }
      }
    } catch (e) {
      print('🦕 Notification send error: $e');
    }
  }



   String extractPlaceNameFromGeofenceId(String geofenceId) {
    try {
      final parts = geofenceId.split('_');
      return parts.length >= 3 ? parts[2] : geofenceId;
    } catch (e) {
      print('Geofence ID parsing error: $e');
      return geofenceId;
    }
  }



   Future<List<String>> fetchValidFcmTokens(List<String> userIds) async {
    final List<String> validTokens = [];

    for (final userId in userIds) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (userDoc.exists) {
          final token = userDoc.get('fcmToken')?.toString();

          if (token != null && token.isNotEmpty && token != 'null') {
            validTokens.add(token);
          } else {
            print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Invalid token for user $userId');

            final newToken = await FirebaseMessaging.instance.getToken();
            if (newToken != null) {
              await updateUserFcmToken(userId, newToken);
              validTokens.add(newToken);
              print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Generated new token for user $userId');
            }
          }
        }
      } catch (e) {
        print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Error fetching token for user $userId: $e');
      }
    }

    return validTokens;
  }


   Future<void> updateUserFcmToken(
    String userId,
    String newToken,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': newToken,
      });
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Updated FCM token for user $userId');
    } catch (e) {
      print('🦕🦕🦕🦕🦕🦕🦕🦕🦕Error updating FCM token: $e');
    }
  }
