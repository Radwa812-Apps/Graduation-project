import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications {
  final String id;
  final String userLocationId;
  final List<String> groupsID; 
  final String type; 
  final String messageLocation;
  final Timestamp timeOfLocation;

  Notifications({
    required this.id,
    required this.userLocationId,
    required this.groupsID, // Updated parameter
    required this.type,
    required this.messageLocation,
    required this.timeOfLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userLocationId': userLocationId,
      'type': type,
      'messageLocation': messageLocation,
      'timeOfLocation': timeOfLocation,
      'groupsID': groupsID,
    };
  }

  factory Notifications.fromMap(Map<String, dynamic> map) {
    return Notifications(
      id: map['id'],
      userLocationId: map['userLocationId'],
      type: map['type'],
      messageLocation: map['messageLocation'],
      timeOfLocation: map['timeOfLocation'],
      groupsID: List<String>.from(map['groupsID']),
    );
  }

  factory Notifications.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    final locationData =
        data['messageLocation'] != null
            ? jsonDecode(data['messageLocation'])
            : {};

    final userName = locationData['userName'] ?? '';
    final eventType = locationData['eventType'] ?? '';
    String geofenceName = locationData['geofenceName'] ?? '';
    final combinedMessage = '$userName $eventType $geofenceName';

    List<String> groupIds = [];
    if (data['groupsID'] != null) {
      if (data['groupsID'] is List) {
        groupIds = List<String>.from(data['groupsID']);
      } else if (data['groupsID'] is String) {
        groupIds = [data['groupsID'] as String];
      }
    }

    return Notifications(
      id: doc.id,
      userLocationId: data['userLocationId'] ?? '',
      type: data['type'] ?? '',
      messageLocation: combinedMessage,
      timeOfLocation:
          data['timeOfLocation'] is Timestamp
              ? data['timeOfLocation'] as Timestamp
              : Timestamp.fromMillisecondsSinceEpoch(
                (data['timeOfLocation'] as int).toInt(),
              ),
      groupsID: groupIds, // Updated field
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'userLocationId': userLocationId,
      'groupsID': groupsID,
      'type': type,
      'messageLocation': messageLocation,
      'timeOfLocation': timeOfLocation,
    };
  }
}
