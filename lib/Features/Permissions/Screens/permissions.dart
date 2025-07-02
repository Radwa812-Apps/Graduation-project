
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Permissions/Compnents/button.dart';
import 'package:near_me_new_version/Features/Permissions/Compnents/permission_tile.dart';
import 'package:near_me_new_version/Features/Permissions/Screens/permission_location.dart';
import 'package:near_me_new_version/components/mainScaffold.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/core/services/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/font_style.dart';

class Permissions extends StatefulWidget {
  const Permissions({super.key});
  static String permissionsKey = '/Permissions';

  @override
  State<Permissions> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> with RouteAware {
  List<bool> switchStatus = [false, false, false, false, false];
  List<bool> permanentlyDenied = [false, false, false, false, false];
  final PermissionHandler _permissionHandler = PermissionHandler();

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _checkAllPermissions();
  }

  void _checkAllPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification,
      Permission.contacts,
    ];

    try {
      final grantedStatuses = <bool>[];
      final deniedPermanentlyStatuses = <bool>[];

      for (var permission in permissions) {
        final status = await permission.status;
        grantedStatuses.add(status.isGranted);
        deniedPermanentlyStatuses.add(status.isPermanentlyDenied);
      }

      if (!mounted) return;

      setState(() {
        switchStatus = grantedStatuses;
        permanentlyDenied = deniedPermanentlyStatuses;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<PermissionStatus> _getPermissionStatus(int index) async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.notification,
      Permission.contacts,
    ];
    return await permissions[index].status;
  }

  Future<void> updateSwitchStatus(int index, bool value) async {
    try {
      final status = await _getPermissionStatus(index);

      if (!mounted) return;

      if (!value) {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Can’t Turn Off Permission'),
                content: Text(
                  'You can’t disable the ${_getPermissionName(index)} permission from here.\n\nPlease go to your phone\'s settings to change it.',
                ),
                actions: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: kSpecialColor, width: 2),
                        borderRadius: BorderRadius.circular(20),
                        color: kSpecialColor,
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        );
        return;
      }

      if (value) {
        bool granted = false;

        switch (index) {
          case 0:
            granted = await _permissionHandler.checkCameraPermission();
            break;
          case 1:
            granted = await _permissionHandler.checkMicrophonePermission();
            break;
          case 2:
            granted = await _permissionHandler.checkStoragePermission();
            break;
          case 3:
            granted = await _permissionHandler.checkNotificationPermission();
            break;
          case 4:
            granted = await _permissionHandler.checkContactPermission();
            break;
        }

        if (!mounted) return;
        setState(() {
          switchStatus[index] = granted;
        });
      } else {
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Can’t Turn Off Permission'),
                content: Text(
                  'To disable the ${_getPermissionName(index)} permission, please go to the phone\'s settings.',
                ),
                actions: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.amber.withOpacity(0.2),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: kSpecialColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        );
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
    final args = ModalRoute.of(context)?.settings.arguments;
    bool anySwitchActive = switchStatus.contains(true);

    final icons = [
      Icons.camera_alt_outlined,
      Icons.mic_none_outlined,
      Icons.folder_outlined,
      Icons.notifications_outlined,
      Icons.contacts_outlined,
    ];

    final titles = [
      'Camera',
      'Microphone',
      'Access files',
      'Notification',
      'Contacts',
    ];

    final subtitles = [
      'Access to your camera to capture photos.',
      'Access to your microphone to record audio.',
      'Access to your files to manage documents.',
      'Allow the app to send you alerts.',
      'Grant access to choose friends.',
    ];

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
                  onTap: () => Navigator.pop(context),
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
                  children: List.generate(5, (index) {
                    return PermissionTile(
                      icon: icons[index],
                      title: titles[index],
                      subtitle: subtitles[index],
                      switchValue: switchStatus[index],
                      onChanged:
                          permanentlyDenied[index]
                              ? null
                              : (value) => updateSwitchStatus(index, value),
                      enabled: !permanentlyDenied[index],
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                if (args != 'SettingScreen')
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
