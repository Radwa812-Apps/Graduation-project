
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/User_Profile/components/button_widget.dart';
import 'package:near_me_new_version/Features/User_Profile/screens/edit_screen.dart';
import 'package:near_me_new_version/core/data/bloc/profile/profile_bloc.dart';
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
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                    height: screenHeight * 0.52.h,
                    decoration: BoxDecoration(
                      color: kPrimaryColor1.withOpacity(.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
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
                          size: Size(screenWidth * 0.5.w, screenHeight * .01.h),
                        ),
                      ],
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
              child: RoundImageWidget(
               // name: kDefaultUserImge,
                width: 110.w,
                height: 110.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
