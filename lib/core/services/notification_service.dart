import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
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
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
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

Future getDeviceToken() async {
   NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
   );
   String ? token = await messaging.getToken(); 
   print( '🤑🤑🤑Device Token: $token');
   return token;  
  }
}
// 