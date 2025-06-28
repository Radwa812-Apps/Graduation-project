import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Screens/map1.dart';
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

class SettingsScreen extends StatelessWidget {
  static String settingsScreenKey = '/SettingsScreen';
  double spaceBetweenRows = 40.h;
  String? email, pass;

  SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: kFontColor,
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: spaceBetweenRows),
              IconAndTextWidget(
                iconData: Icons.near_me_outlined,
                text: 'Start Tracking',
                iconSize: 25.sp,
                fontSize: 22.sp,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    TrackingScreen.trackingMapScreenKey,
                  );
                },
              ),

              SizedBox(height: spaceBetweenRows),
              IconAndTextWidget(
                iconData: Icons.location_on_outlined,
                text: 'Add Place',
                iconSize: 25.sp,
                fontSize: 22.sp,
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
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SettingsService(),
              ),
              SizedBox(height: spaceBetweenRows),
              IconAndTextWidget(
                iconData: Icons.share_outlined,
                text: 'Share',
                iconSize: 25.sp,
                fontSize: 22.sp,
                onTap: () {
                  Share.share(
                    'جربوا تطبيقي الجديد! ❤️\n(الرابط هيبقى هنا لما التطبيق ينزل)',
                    subject: 'تطبيقي الجديد!',
                  );
                },
              ),
              SizedBox(height: spaceBetweenRows),
              IconAndTextWidget(
                iconData: Icons.qr_code_2_outlined,
                text: 'QR Code',
                iconSize: 25.sp,
                fontSize: 22.sp,
                onTap: () {},
              ),
              SizedBox(height: spaceBetweenRows),
              IconAndTextWidget(
                iconData: Icons.logout_outlined,
                text: 'Logout',
                iconSize: 25.sp,
                fontSize: 22.sp,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmMessageWidget(
                        message: 'Are you sure you want to leave?',
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                        onConfirm: () async {
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.clear();
                          await FirebaseAuth.instance.signOut();

                          GoogleSignIn googleSignIn = GoogleSignIn();
                          await googleSignIn.signOut();
                          await FirebaseAuth.instance.signOut();
                          Navigator.popAndPushNamed(
                            context,
                            SignInScreen.signInScreenKey,
                          );
                        },
                      );
                    },
                  );
                },
              ),
              SizedBox(height: spaceBetweenRows),
              IconAndTextWidget(
                iconData: Icons.lock_outline,
                text: 'Password',
                iconSize: 25.sp,
                fontSize: 22.sp,
                onTap: () {},
              ),
              SizedBox(height: spaceBetweenRows),
              IconAndTextWidget(
                iconData: Icons.perm_device_information_sharp,
                text: 'Permissions',
                iconSize: 25.sp,
                fontSize: 22.sp,
                onTap: () {
                  Navigator.pushNamed(context, '/permissions');
                },
              ),
              SizedBox(height: spaceBetweenRows),
              BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {
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
                    return AppMessages().sendVerification(
                      context,
                      Colors.red.withOpacity(0.6),
                      'Failed to delete account: ${state.error}',
                    );
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) =>
                              const Center(child: CircularProgressIndicator()),
                    );
                  }
                },
                builder: (context, state) {
                  return IconAndTextWidget(
                    iconData: Icons.delete_forever_outlined,
                    text: 'Delete Account',
                    iconSize: 25.sp,
                    fontSize: 22.sp,
                    onTap: () {
                      TextEditingController emailController =
                          TextEditingController();
                      TextEditingController passwordController =
                          TextEditingController();
                      GlobalKey<FormState> formKey = GlobalKey<FormState>();

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: kPrimaryColor2,
                            title: const Text(
                              "Confirm Account Deletion",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextFormFieldWidget(
                                    lineFocusColor: kFontColor,
                                    hintColor: Colors.grey,
                                    lineColor: Colors.grey,
                                    controller: emailController,
                                    hint: 'Email',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Colors.grey,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validatior: ((p0) {
                                      if (p0 == null || p0.isEmpty) {
                                        return "Email is required.";
                                      }
                                      return null;
                                    }),
                                    onchange: ((p0) {
                                      email = p0;
                                    }),
                                    editIcon: null,
                                  ),
                                  SizedBox(height: 30.h),
                                  TextFormFieldWidget(
                                    lineFocusColor: kFontColor,
                                    hintColor: Colors.grey,
                                    lineColor: Colors.grey,
                                    controller: passwordController,
                                    hint: 'Password',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey,
                                    ),
                                    keyboardType: TextInputType.text,
                                    isPassword: true,
                                    validatior: ((p0) {
                                      if (p0 == null || p0.isEmpty) {
                                        return "PassWord is required.";
                                      }
                                      return null;
                                    }),
                                    onchange: ((p0) {
                                      pass = p0;
                                    }),
                                    editIcon: null,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: 40.h,
                                    width: 70.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: kPrimaryColor1,
                                    ),
                                    child: TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40.h,
                                    width: 70.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.red,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          BlocProvider.of<ProfileBloc>(
                                            context,
                                          ).add(DeleteUserEvent(pass!, email!));
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30.h),
                            ],
                          );
                        },
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
  }
}
