import 'package:cloud_firestore/cloud_firestore.dart';

class GroupRiskAlert {
  final String id;
  final String groupId;
  final String riskAlertId;
  final Timestamp assignedAt;

  GroupRiskAlert({
    required this.id,
    required this.groupId,
    required this.riskAlertId,
    required this.assignedAt,
  });

  factory GroupRiskAlert.fromJson(Map<String, dynamic> json,String id) {
    return GroupRiskAlert(
      id: id,
      groupId: json['groupId'] as String,
      riskAlertId: json['riskAlertId'] as String,
      assignedAt: json['assignedAt'] as Timestamp,
    );
  }
}
