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
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';
import '../../../../core/constants.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final isMediumScreen =
            constraints.maxHeight >= 600 && constraints.maxHeight < 800;

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top:
                      widget.paddingTopContainer! * (isSmallScreen ? 0.8 : 1.0),
                ),
                child: BlocConsumer<ProfileBloc, ProfileState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is UserInfoLoadedSuccessState) {
                      return Container(
                        width:
                            isSmallScreen
                                ? constraints.maxWidth * 0.90
                                : constraints.maxWidth * 0.80,
                        decoration: BoxDecoration(
                          color: kPrimaryColor1.withOpacity(.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 15.h : 20.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: isSmallScreen ? 50.h : 60.h),
                              Text(
                                'Welcome ${state.userModel.fName[0].toUpperCase()}${state.userModel.fName.substring(1)}',
                                style: TextStyle(
                                  color: kFontColor,
                                  fontFamily: kFontBold,
                                  fontSize: isSmallScreen ? 22.sp : 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isSmallScreen ? 15.h : 20.h),
                              _buildResponsiveInfoWidget(
                                context,
                                state.userModel.fName,
                                Icons.person_outlined,
                                isSmallScreen,
                              ),
                              SizedBox(
                                height:
                                    widget.spaceWithRows *
                                    (isSmallScreen ? 0.8 : 1.0),
                              ),
                              _buildResponsiveInfoWidget(
                                context,
                                state.userModel.lName,
                                Icons.group_outlined,
                                isSmallScreen,
                              ),
                              SizedBox(
                                height:
                                    widget.spaceWithRows *
                                    (isSmallScreen ? 0.8 : 1.0),
                              ),
                              _buildResponsiveInfoWidget(
                                context,
                                state.userModel.phoneNumber
                                    .split("number: ")[1]
                                    .replaceAll(")", ""),
                                Icons.phone_outlined,
                                isSmallScreen,
                              ),
                              SizedBox(
                                height:
                                    widget.spaceWithRows *
                                    (isSmallScreen ? 0.8 : 1.0),
                              ),
                              _buildResponsiveInfoWidget(
                                context,
                                state.userModel.email.length > 25
                                    ? '${state.userModel.email.substring(0, 22)}...'
                                    : state.userModel.email,
                                Icons.email_outlined,
                                isSmallScreen,
                              ),
                              SizedBox(
                                height:
                                    widget.spaceWithRows *
                                    (isSmallScreen ? 0.8 : 1.0),
                              ),
                              _buildResponsiveInfoWidget(
                                context,
                                state.userModel.dateOfBirth,
                                Icons.calendar_month_outlined,
                                isSmallScreen,
                              ),
                              SizedBox(height: isSmallScreen ? 15.h : 25.h),
                              _buildResponsiveButton(
                                context,
                                isSmallScreen,
                                constraints,
                                state,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is UserInfoErrorState) {
                      return Center(
                        child: Text(
                          'Something went wrong: ${state.error}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14.sp : 16.sp,
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(color: kPrimaryColor1),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: widget.imagePositionTop! * (isSmallScreen ? 0.9 : 1.0),
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: isSmallScreen ? 55 : 70,
                    backgroundColor: kPrimaryColor1.withOpacity(0.2),
                    backgroundImage:
                        userImage != null
                            ? MemoryImage(userImage!)
                            : const AssetImage(kDefaultUserImge)
                                as ImageProvider,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveInfoWidget(
    BuildContext context,
    String info,
    IconData iconData,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10.w : 15.w),
      child: UserProfileInfoWidget(
        info: info,
        iconData: iconData,
        size: isSmallScreen ? 20.sp : 25.sp,
      ),
    );
  }

  Widget _buildResponsiveButton(
    BuildContext context,
    bool isSmallScreen,
    BoxConstraints constraints,
    UserInfoLoadedSuccessState state,
  ) {
    return ButtonWidget(
      name: 'Edit',
      fontSize: isSmallScreen ? 18.sp : 23.sp,
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
        Navigator.pushNamed(context, EditScreen.editScreenKey);
      },
      size: Size(
        constraints.maxWidth * (isSmallScreen ? 0.35 : 0.4),
        isSmallScreen ? 35.h : 40.h,
      ),
    );
  }
}
