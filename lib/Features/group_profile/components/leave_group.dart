import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Home/Home/Screens/home_screen.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/main.dart';

class LeaveGroup extends StatelessWidget {
  final String groupId;
  final VoidCallback? onSuccess;

  const LeaveGroup({
    Key? key,
    required this.groupId,
    this.onSuccess,
  }) : super(key: key);

  Future<void> _leaveGroup(BuildContext context) async {
    try {
      await GroupService().leaveGroup(groupId);
      if (onSuccess != null) {
        onSuccess!();
      } else {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          HomeScreen.homeScreenKey,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave group: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.exit_to_app, size: 40, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Leave Group?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kFontColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to leave this group?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryColor1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: kFontColor)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext); 
                          await Future.delayed(const Duration(milliseconds: 100));
                          await _leaveGroup(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Leave', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLeaveDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.exit_to_app, color: Colors.red, size: 30),
            SizedBox(width: 15),
            Text(
              'Leave Group',
              style: TextStyle(
                color: kFontColor,
                fontFamily: kFontRegular,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
