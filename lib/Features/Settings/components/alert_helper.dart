import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getSelectedGroupsFromFirebase(String userId) async {
  final doc = await FirebaseFirestore.instance
      .collection('selected_alert_groups')
      .doc(userId)
      .get();

  if (doc.exists) {
    final data = doc.data();
    if (data != null && data['groups'] is List) {
      return List<String>.from(data['groups']);
    }
  }
  return [];
}
Future<void> sendAlertToGroups(List<String> groupIds) async {
  for (final groupId in groupIds) {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .update({'alert': true});
  }
}
