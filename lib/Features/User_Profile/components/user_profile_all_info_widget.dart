import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/User_Profile/components/button_widget.dart';
import 'package:near_me_new_version/Features/User_Profile/screens/edit_screen.dart';
import 'package:near_me_new_version/core/data/bloc/profile/profile_bloc.dart';
//import 'package:near_me_new_version/core/data/models/userRadwa.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';
import '../../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';
import 'user_profile_info_widget.dart';

class UserProfileAll_InfoWidget extends StatefulWidget {
  const UserProfileAll_InfoWidget({
    super.key,
    required this.spaceWithRows,
    required this.imagePositionTop,
    required this.paddingTopContainer,
  });

  final double spaceWithRows;
  final double? imagePositionTop;
  final double? paddingTopContainer;

  @override
  State<UserProfileAll_InfoWidget> createState() =>
      _UserProfileAll_InfoWidgetState();
}

class _UserProfileAll_InfoWidgetState extends State<UserProfileAll_InfoWidget> {
  bool _isLoading = false;
  final ProfileImageService _profileImageService = ProfileImageService();
  final GroupService _groupService = GroupService();
  Uint8List? userImage;
  late final StreamSubscription _subscription;
  @override
  void initState() {
    super.initState();
    _loadUserImage();
  }

  void _loadUserImage() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not authenticated"),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    if (user != null) {
      final image = await ProfileImageService().getDecryptedUserImage(user.uid);
      if (image != null && mounted) {
        setState(() {
          userImage = image;
        });
      }
    }
  }

  void _listenToUserChanges() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      log("User not authenticated");
      return;
    }
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) async {
          if (snapshot.exists) {
            final triggered = snapshot.data()?['encryptedUserPicture'] ?? '';
            if (mounted) {
              setState(() {
                _loadUserImage();
              });
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    ImageProvider imageProvider = const AssetImage(kDefaultUserImge);
    if (userImage != null) {
      imageProvider = MemoryImage(userImage!);
    }
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: widget.paddingTopContainer!),
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is UserInfoLoadedSuccessState) {
                  return Container(
                    width: screenWidth * 0.80.w,
                    // height: screenHeight * 0.52.h,
                    decoration: BoxDecoration(
                      color: kPrimaryColor1.withOpacity(.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: screenWidth * 0.13.w),
                          Text(
                            'Welcome ${state.userModel.fName[0].toUpperCase()}${state.userModel.fName.substring(1)}',
                            style: TextStyle(
                              color: kFontColor,
                              fontFamily: kFontBold,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.08.w),
                          UserProfileInfoWidget(
                            info: state.userModel.fName,
                            iconData: Icons.person_outlined,
                            size: 25.sp,
                          ),
                          SizedBox(height: widget.spaceWithRows),
                          UserProfileInfoWidget(
                            info: state.userModel.lName,
                            iconData: Icons.group_outlined,
                            size: 25.sp,
                          ),
                          SizedBox(height: widget.spaceWithRows),
                          UserProfileInfoWidget(
                            info: state.userModel.phoneNumber
                                .split("number: ")[1]
                                .replaceAll(")", ""),
                            iconData: Icons.phone_outlined,
                            size: 25.sp,
                          ),
                          SizedBox(height: widget.spaceWithRows),
                          UserProfileInfoWidget(
                            info:
                                state.userModel.email.length > 25
                                    ? '${state.userModel.email.substring(0, 22)}...'
                                    : state.userModel.email,
                            iconData: Icons.email_outlined,
                            size: 25.sp,
                          ),
                          SizedBox(height: widget.spaceWithRows),
                          UserProfileInfoWidget(
                            info: state.userModel.dateOfBirth,
                            iconData: Icons.calendar_month_outlined,
                            size: 25.sp,
                          ),
                          SizedBox(height: screenWidth * 0.1.w),
                          ButtonWidget(
                            name: 'Edit',
                            fontSize: 23.sp,
                            onTap: () {
                              BlocProvider.of<ProfileBloc>(context).add(
                                EditUserEvent(
                                  dateOfBirth: state.userModel.dateOfBirth,
                                  email: state.userModel.email,
                                  lName: state.userModel.lName,
                                  fName: state.userModel.fName,
                                  phoneNumber: state.userModel.phoneNumber,
                                ),
                              );
                              Navigator.pushNamed(
                                context,
                                EditScreen.editScreenKey,
                              );
                            },
                            size: Size(
                              screenWidth * 0.4.w,
                              screenHeight * .01.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is UserInfoErrorState) {
                  return Center(
                    child: Text('Something went wrong: ${state.error}'),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Positioned(
            top: widget.imagePositionTop,
            left: 0,
            right: 0,

            child: Center(
              child: CircleAvatar(radius: 70, backgroundImage: imageProvider),

              // RoundImageWidget(
              //   // assetImagePath: kDefaultUserImge, // Uncomment if you want to use a default asset image
              //  // name: kDefaultUserImge,
              //   width: 110.w,
              //   height: 110.h,
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
