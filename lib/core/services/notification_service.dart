import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:near_me_new_version/Features/Private_chat/Private_chat/screens/private_chat_screen.dart';
import 'package:near_me_new_version/Features/chat_group/screens/group_chat.dart';
import 'package:near_me_new_version/core/services/send_notification_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late BuildContext _context;

  Future<void> initialize(BuildContext context) async {
    _context = context;
    await requestNotificationPermission();
    await _initializeLocalNotifications();
    _setupFirebaseListeners();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // Add iOS settings if needed
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          handleNotificationNavigation(_context, data);
        }
      },
    );
  }

  static void handleNotificationNavigation(BuildContext context, Map<String, dynamic> data) {
    try {
      final type = data['type'];
      if (type == 'private_chat') {
        Navigator.pushNamed(
          context,
          PrivateChatScreen.privateChatScreenKey,
          arguments: {
            'recipientId': data['recipientId'],
            'recipientName': data['senderName'],
            'recipientImage': null, // You can pass image if available
          },
        );
      } else if (type == 'group_chat') {
        Navigator.pushNamed(
          context,
          GroupChat.routeName,
          arguments: {
            'groupId': data['groupId'],
            'groupName': data['groupName'],
          },
        );
      }
    } catch (e) {
      print('Error handling notification navigation: $e');
    }
  }

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      SnackBar snackBar = SnackBar(
        content: Text(
          'User declined permission, Allow notifications in settings',
        ),
      );

      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
      print('User declined or has not accepted permission');
    }
  }

  Future<String?> getDeviceToken() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    String? token = await _firebaseMessaging.getToken(); 
    print('🤑🤑🤑Device Token: $token');
    return token;  
  }

  void _setupFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        handleNotificationNavigation(_context, message.data);
      }
      print('Message opened from notification: ${message.notification?.title}');
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_channel', // channel id
      'Chat Notifications', // channel name
      channelDescription: 'This channel is used for chat notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> sendChatNotification({
    required String recipientToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await SendNotificationService.sendNotificationUsingApi(
      fcmToken: recipientToken,
      title: title,
      body: body,
      data: data,
    );
  }
}