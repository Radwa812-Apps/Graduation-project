import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Screens/map1.dart';
import 'package:near_me_new_version/Features/Notifications/Components/date_label.dart';
import 'package:near_me_new_version/Features/Notifications/Components/header_notifications.dart';
import 'package:near_me_new_version/Features/Notifications/Components/notification_item.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/group_notifications.dart';
import 'package:near_me_new_version/Features/Permissions/Compnents/button.dart';
import 'package:near_me_new_version/Features/Permissions/Compnents/permission_tile.dart';
import 'package:near_me_new_version/Features/Permissions/Screens/permission_location.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/core/font_style.dart';
import '../../../core/constants.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/messages.dart';
import '../../../core/services/permission_handler.dart';

class Permissions extends StatefulWidget {
  const Permissions({super.key});
  static String permissionsKey = '/Permissions';
  @override
  _PermissionsState createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  List<bool> switchStatus = [false, false, false, false, false];
  final PermissionHandler _permissionHandler = PermissionHandler();
  Future<void> updateSwitchStatus(int index, bool value) async {
    bool permissionGranted = false;

    try {
      if (value) {
        switch (index) {
          case 0:
            permissionGranted =
                await _permissionHandler.checkCameraPermission();
            break;
          case 1:
            permissionGranted =
                await _permissionHandler.checkMicrophonePermission();
            break;
          case 2:
            permissionGranted =
                await _permissionHandler.checkStoragePermission();
            break;
          case 3:
            permissionGranted =
                await _permissionHandler.checkNotificationPermission();
            break;
          case 4:
            permissionGranted =
                await _permissionHandler.checkContactPermission();
            break;
        }
      } else {
        permissionGranted = false;
      }

      setState(() {
        switchStatus[index] = permissionGranted;
      });

      if (!permissionGranted && value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission not granted for ${_getPermissionName(index)}. Please enable it manually in settings.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
        );
      } else if (permissionGranted && value) {
        // ignore: use_build_context_synchronously
        // AppMessages().sendVerification(context, Colors.red.withOpacity(0.5),
        //     'Permission already granted for ${_getPermissionName(index)}');
      } else if (!value) {
        // ignore: use_build_context_synchronously
        AppMessages().sendVerification(
          context,
          Colors.red.withOpacity(0.5),
          'Permission denied for ${_getPermissionName(index)}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getPermissionName(int index) {
    switch (index) {
      case 0:
        return 'Camera';
      case 1:
        return 'Microphone';
      case 2:
        return 'Storage';
      case 3:
        return 'Notifications';
      case 4:
        return 'Contacts';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool anySwitchActive = switchStatus.contains(true);
    final args = ModalRoute.of(context)?.settings.arguments;
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
                Center(
                  child: Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 38.sp,
                      fontFamily: 'OpenSans-Regular',
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PermissionTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera',
                      subtitle: 'Access to your camera to capture photos.',
                      switchValue: switchStatus[0],
                      onChanged: (value) => updateSwitchStatus(0, value),
                    ),
                    PermissionTile(
                      icon: Icons.mic_none_outlined,
                      title: 'Microphone',
                      subtitle:
                          'Access to your microphone to record audio or enable voice-based services.',
                      switchValue: switchStatus[1],
                      onChanged: (value) => updateSwitchStatus(1, value),
                    ),
                    PermissionTile(
                      icon: Icons.folder_outlined,
                      title: 'Access files',
                      subtitle:
                          'Access to your files to upload or manage documents.',
                      switchValue: switchStatus[2],
                      onChanged: (value) => updateSwitchStatus(2, value),
                    ),
                    PermissionTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notification',
                      subtitle: 'Allow the app to send you alerts and updates.',
                      switchValue: switchStatus[3],
                      onChanged: (value) => updateSwitchStatus(3, value),
                    ),
                    PermissionTile(
                      icon: Icons.contacts_outlined,
                      title: 'Contacts',
                      subtitle: 'Grant access to choose friends.',
                      switchValue: switchStatus[4],
                      onChanged: (value) => updateSwitchStatus(4, value),
                    ),
                    SizedBox(height: 20.h),
                    if (args != 'SettingScreen')
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  PermissionLocation.permissionLocationKey,
                                );
                              },
                              style: AppButtonStyles.elevatedButtonStyle(),
                              child: Text(
                                anySwitchActive ? 'Next' : 'Skip',
                                style: TextStyles.permissionButtonText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
