
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/personal_notifications.dart';

class GroupNotiElement extends StatelessWidget {
  const GroupNotiElement({
    super.key,
    required this.notificationContent,
    required this.notificationTime,
    required this.groupId, required this.userId,
   
  });
final String userId;
  final String groupId;
  final String notificationContent;
  final String notificationTime;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/user.jpg', // Replace with your image
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        notificationContent,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(notificationTime, style: TextStyle(color: Colors.grey)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    PersonalNotifications(groupId: groupId, userId: userId,title:extractUsername(notificationContent), ),
          ),
        );
      },
      trailing: true ? Icon(Icons.arrow_forward_ios) : null,
    );
  }
}

String extractUsername(String notificationContent) {
  try {
    final parts = notificationContent.split('-');
    if (parts.isNotEmpty) {
      return parts[0];
    }
    return 'Unknown';
  } catch (e) {
    return 'Unknown';
  }
}
