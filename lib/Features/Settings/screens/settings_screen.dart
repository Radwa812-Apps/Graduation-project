import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Screens/map1.dart';
import 'package:near_me_new_version/Features/Permissions/Screens/permissions.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_in_screen.dart';
import 'package:near_me_new_version/Features/group_profile/screens/tracking.dart';
import 'package:near_me_new_version/core/data/bloc/profile/profile_bloc.dart';
import 'package:near_me_new_version/core/messages.dart';
import 'package:near_me_new_version/core/services/settings_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/Sign_up_and_in/components/text_form_widget.dart';
import '../components/confirm_message_widget.dart';
import '../components/icon_and_text_widget.dart';

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SettingsScreen extends StatelessWidget {
  static String settingsScreenKey = '/SettingsScreen';
  String? email, pass;

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديد المسافات والأحجام بناءً على حجم الشاشة
    final double spaceBetweenRows = 0.04.sh;
    final double appBarHeight = 0.1.sh;
    final double iconSize = 24.sp;
    final double fontSize = 20.sp;
    final double dialogPadding = 20.w;
    final double buttonHorizontalPadding = 25.w;
    final double buttonVerticalPadding = 12.h;
    final double dialogTextSize = 20.sp;
    final double buttonTextSize = 16.sp;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
            color: Colors.transparent,
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Settings',
                style: TextStyle(
                  color: kFontColor,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: spaceBetweenRows),
                    _buildSettingsItem(
                      context,
                      icon: Icons.near_me_outlined,
                      text: 'Start Tracking',
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          TrackingScreen.trackingMapScreenKey,
                        );
                      },
                    ),
                    SizedBox(height: spaceBetweenRows),
                    _buildSettingsItem(
                      context,
                      icon: Icons.location_on_outlined,
                      text: 'Add Place',
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Map1.map1Key,
                          arguments: 'SettingsScreen',
                        );
                      },
                    ),
                    SizedBox(height: spaceBetweenRows),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: SettingsService(),
                    ),
                    SizedBox(height: spaceBetweenRows),
                    _buildSettingsItem(
                      context,
                      icon: Icons.share_outlined,
                      text: 'Share',
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () {
                        Share.share(
                          'جربوا تطبيقي الجديد! ❤️\n(الرابط هيبقى هنا لما التطبيق ينزل)',
                          subject: 'تطبيقي الجديد!',
                        );
                      },
                    ),
                    SizedBox(height: spaceBetweenRows),
                    _buildSettingsItem(
                      context,
                      icon: Icons.qr_code_2_outlined,
                      text: 'QR Code',
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () {},
                    ),
                    SizedBox(height: spaceBetweenRows),
                    _buildSettingsItem(
                      context,
                      icon: Icons.logout_outlined,
                      text: 'Logout',
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () {
                        _showLogoutConfirmation(context);
                      },
                    ),
                    SizedBox(height: spaceBetweenRows),
                    _buildSettingsItem(
                      context,
                      icon: Icons.lock_outline,
                      text: 'Password',
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () {},
                    ),
                    SizedBox(height: spaceBetweenRows),
                    _buildSettingsItem(
                      context,
                      icon: Icons.perm_device_information_sharp,
                      text: 'Permissions',
                      iconSize: iconSize,
                      fontSize: fontSize,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Permissions.permissionsKey,
                          arguments: 'SettingScreen',
                        );
                      },
                    ),
                    SizedBox(height: spaceBetweenRows),
                    BlocConsumer<ProfileBloc, ProfileState>(
                      listener: (context, state) {
                        _handleDeleteAccountState(context, state);
                      },
                      builder: (context, state) {
                        return _buildSettingsItem(
                          context,
                          icon: Icons.delete_forever_outlined,
                          text: 'Delete Account',
                          iconSize: iconSize,
                          fontSize: fontSize,
                          iconColor: Colors.red[400],
                          textColor: Colors.red[400],
                          onTap: () {
                            _showDeleteAccountDialog(
                              context,
                              dialogPadding: dialogPadding,
                              buttonHorizontalPadding: buttonHorizontalPadding,
                              buttonVerticalPadding: buttonVerticalPadding,
                              dialogTextSize: dialogTextSize,
                              buttonTextSize: buttonTextSize,
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: spaceBetweenRows),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    Color? iconColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: iconSize, color: iconColor ?? kFontColor),
              SizedBox(width: 20.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor ?? kFontColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400.w),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    'Are you sure you want to leave?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      // fontWeight: FontWeight.bold,
                      color: kFontColor,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSpecialColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 12.h,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                            vertical: 12.h,
                          ),
                        ),
                        onPressed: () async {
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.clear();
                          await FirebaseAuth.instance.signOut();
                          await GoogleSignIn().signOut();

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            SignInScreen.signInScreenKey,
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context, {
    required double dialogPadding,
    required double buttonHorizontalPadding,
    required double buttonVerticalPadding,
    required double dialogTextSize,
    required double buttonTextSize,
  }) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ), // إضافة هذا السطر
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400.w, // تحديد أقصى عرض للديالوج
            ),
            child: Padding(
              padding: EdgeInsets.all(dialogPadding),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: dialogTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300.w, // تحديد عرض حقول الإدخال
                            child: TextFormFieldWidget(
                              editIcon: null,
                              color: Colors.black87,
                              lineFocusColor: Colors.red[300]!,
                              hintColor: Colors.grey[600]!,
                              lineColor: Colors.grey[400]!,
                              controller: emailController,
                              hint: 'Email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey[600],
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validatior: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                              onchange: (value) => email = value,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 300.w, // تحديد عرض حقول الإدخال
                            child: TextFormFieldWidget(
                              editIcon: null,
                              color: Colors.black87,
                              lineFocusColor: Colors.red[300]!,
                              hintColor: Colors.grey[600]!,
                              lineColor: Colors.grey[400]!,
                              controller: passwordController,
                              hint: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[600],
                              ),
                              keyboardType: TextInputType.text,
                              isPassword: true,
                              validatior: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                              onchange: (value) => pass = value,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSpecialColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: buttonHorizontalPadding,
                              vertical: buttonVerticalPadding,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonTextSize,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: buttonHorizontalPadding,
                              vertical: buttonVerticalPadding,
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              BlocProvider.of<ProfileBloc>(
                                context,
                              ).add(DeleteUserEvent(pass!, email!));
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonTextSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleDeleteAccountState(BuildContext context, ProfileState state) {
    if (state is UserDeletedSuccessState) {
      Navigator.of(context, rootNavigator: true).pop();
      AppMessages().sendVerification(
        context,
        Colors.green.withOpacity(0.6),
        'Your account deleted successfully',
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        SignInScreen.signInScreenKey,
        (route) => false,
      );
    } else if (state is UserDeleteErrorState) {
      Navigator.of(context, rootNavigator: true).pop();
      AppMessages().sendVerification(
        context,
        Colors.red.withOpacity(0.6),
        'Failed to delete account: ${state.error}',
      );
    } else {
      // هذه الحالة تغني عن UserDeletingState
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor1),
              ),
            ),
      );
    }
  }
}
