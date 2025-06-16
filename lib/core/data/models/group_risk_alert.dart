import 'package:cloud_firestore/cloud_firestore.dart';

class GroupRiskAlert {
  final String id;
  final List<String> groupIds;
  final String userId;
  final Timestamp timestamp;
  final String status;
  final List<String>? groupNames;

  GroupRiskAlert({
    required this.id,
    required this.groupIds,
    required this.userId,
    required this.timestamp,
    this.status = 'active',
    this.groupNames,
  });

  factory GroupRiskAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupRiskAlert(
      id: doc.id,
      groupIds: List<String>.from(data['groupIds']),
      userId: data['userId'] as String,
      timestamp: data['timestamp'] as Timestamp,
      status: data['status'] as String? ?? 'active',
      groupNames:
          data['groupNames'] != null
              ? List<String>.from(data['groupNames'])
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupIds': groupIds,
      'userId': userId,
      'timestamp': timestamp,
      'status': status,
      if (groupNames != null) 'groupNames': groupNames,
    };
  }
}
