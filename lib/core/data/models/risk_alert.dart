import 'package:cloud_firestore/cloud_firestore.dart';

class RiskAlert {
  final String id;
  final String groupId;
  final String riskGroupId;
  final String userLocationId;

  RiskAlert({
    required this.id,
    required this.groupId,
    required this.riskGroupId,
    required this.userLocationId,
  });

  factory RiskAlert.fromJson(Map<String, dynamic> json, String id) {
    return RiskAlert(
      id: id,
      groupId: json['groupId'] as String,
      riskGroupId: json['riskGroupId'],
      userLocationId: json['userId'] as String,
    );
  }
}
