import 'package:native_geofence/native_geofence.dart';

class NotificationSentCache {
  static final Map<String, DateTime> _sentNotifications = {};

  static bool shouldSendNotification(String userId, String geofenceId, GeofenceEvent event) {
    final key = '${userId}_${geofenceId}_${event.toString()}';
    
    if (_sentNotifications.containsKey(key)) {
      final lastSent = _sentNotifications[key]!;
      if (DateTime.now().difference(lastSent) < Duration(minutes: 5)) {
        return false;
      }
    }
    
    _sentNotifications[key] = DateTime.now();
    return true;
  }
}