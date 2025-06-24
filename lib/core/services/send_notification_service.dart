
import 'dart:convert';

import 'package:near_me_new_version/core/services/get_service_key.dart';
import 'package:http/http.dart' as http;
class SendNotificationService {
  static Future<void> sendNotificationUsingApi({
    required String fcmToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    String serverKey = await GetServerKey().getServerKeyToken();
    String url =
        'https://fcm.googleapis.com/v1/projects/new-version-nearme/messages:send';

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    Map<String, dynamic> message = {
      "message": {
        "token": fcmToken,
        "notification": {"title": title, "body": body},
        "data": data,
      },
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('😍😍Notification sent successfully');
    } else {
      print('😍😍Failed to send notification: ${response.statusCode}');
      print('😍😍 Response body: ${response.body}');
    } 
  }
}
