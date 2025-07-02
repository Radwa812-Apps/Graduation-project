import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Screens/map1.dart';
import 'package:near_me_new_version/Features/Permissions/Compnents/button.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/custom_back_button.dart';
import 'package:near_me_new_version/core/font_style.dart';
import '../../../core/constants.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/permission_handler.dart';

class PermissionLocation extends StatefulWidget {
  const PermissionLocation({super.key});

  @override
  _PermissionLocationState createState() => _PermissionLocationState();
  static String permissionLocationKey = '/PermissionLocation';
}

class _PermissionLocationState extends State<PermissionLocation> {
  bool isSwitchOn = false;
  final PermissionHandler _permissionHandler = PermissionHandler();
  bool permissionGranted = false;

  void updateSwitchStatus(int index, bool value) async {
    bool permissionGranted = false;

    try {
      switch (index) {
        case 0:
          permissionGranted =
              await _permissionHandler.checkLocationPermission();
      }

      setState(() {
        isSwitchOn = permissionGranted;
      });

      if (!permissionGranted) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Permission not granted for ${_getPermissionName(index)}. Please enable it manually in settings.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ),
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
        return 'Location';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBackButton(
                  ontap: (() => Navigator.pop(context)),
                  icon: Icons.arrow_back_ios_outlined),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Turn on your location',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),
                      Container(
                        padding: const EdgeInsets.all(40.0),
                        decoration: BoxDecoration(
                          color: spectialgreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/Rectangle253.png',
                              height: 150,
                            ),
                            SizedBox(height: 20.h),
                            Switch(
                              value: isSwitchOn,
                              onChanged: (value) =>
                                  updateSwitchStatus(0, value),
                              activeColor: kPrimaryColor1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: spectialgreen,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Text(
                              'This is an important step to continue using our app',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Positioned(
                              bottom: -10.h,
                              left: 20.w,
                              child: CustomPaint(
                                size: const Size(10, 10),
                                painter: TrianglePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSwitchOn)
                Row(
                  children: [
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Map1.map1Key,
                            arguments: 'PermissionLocation');
                      },
                      style: AppButtonStyles.elevatedButtonStyle(),
                      child: const Text(
                        'Next',
                        style: TextStyles.permissionButtonText,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
