import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/core/data/bloc/profile/profile_bloc.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:near_me_new_version/core/services/validator.dart';
import '../../../../core/constants.dart';
import '../../../core/services/profile_image_service.dart';
import '../../Auth/Sign_up_and_in/components/phone_widget.dart';
import '../../Home/Home/components/round_image_widget.dart';
import '../../auth/Sign_up_and_in/components/functions.dart';
import 'edit_text_field.dart';
import 'button_widget.dart';

class EditUserWidget extends StatefulWidget {
  static String editUserWidgetKey = '/EditUserWidget';

  final double spaceWithRows;
  final double imagePositionTop;
  final double paddingTopContainer;

  const EditUserWidget({
    super.key,
    required this.spaceWithRows,
    required this.imagePositionTop,
    required this.paddingTopContainer,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditUserWidgetState createState() => _EditUserWidgetState();
}

class _EditUserWidgetState extends State<EditUserWidget> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormFieldState> name = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> name2 = GlobalKey<FormFieldState>();
  bool isChanged = false;
  String? fName, lName, password, email, phoneNumber, dateOfBirth;
  void onFieldChanged(String value) {
    setState(() {
      isChanged = true;
    });
  }

  bool _isLoading = false;
  Uint8List? userImage;
  final ProfileImageService _profileImageService = ProfileImageService();
  final GroupService _groupService = GroupService();
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد الأبعاد بناءً على حجم الشاشة
        final bool isSmallScreen = constraints.maxHeight < 700;
        final bool isMediumScreen =
            constraints.maxHeight >= 700 && constraints.maxHeight < 900;

        // ضبط أحجام الخطوط بشكل ديناميكي
        final double titleFontSize =
            isSmallScreen
                ? 20.sp
                : isMediumScreen
                ? 24.sp
                : 26.sp;
        final double fieldFontSize =
            isSmallScreen
                ? 11.sp
                : isMediumScreen
                ? 13.sp
                : 15.sp;
        final double buttonFontSize =
            isSmallScreen
                ? 16.sp
                : isMediumScreen
                ? 17.sp
                : 18.sp;

        // ضبط الأبعاد الأخرى
        final double imagePositionTop = isSmallScreen ? -30.h : 25.h;
        final double paddingTopContainer = isSmallScreen ? 70.h : 100.h;
        final double spaceBetweenFields = isSmallScreen ? 15.h : 25.h;
        final double buttonHeight = isSmallScreen ? 50.h : 65.h;
        final double buttonWidth = isSmallScreen ? 80.w : 100.w;
        final double avatarRadius = isSmallScreen ? 50.r : 70.r;

        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is UserEditedSuccessState) {
              return Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(top: paddingTopContainer),
                        child: Container(
                          width: constraints.maxWidth * 0.85,
                          decoration: BoxDecoration(
                            color: kPrimaryColor1.withOpacity(.20),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: avatarRadius + 20.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Text(
                                  'Edit Your Profile',
                                  style: TextStyle(
                                    color: kFontColor,
                                    fontFamily: kFontBold,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: spaceBetweenFields),

                              // حقول الإدخال
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Column(
                                  children: [
                                    _buildEditTextField(
                                      context,
                                      state.userModel.fName,
                                      Icons.person_outlined,
                                      firstNameController,
                                      name,
                                      'First Name',
                                      fieldFontSize,
                                    ),
                                    SizedBox(height: spaceBetweenFields),
                                    _buildEditTextField(
                                      context,
                                      state.userModel.lName,
                                      Icons.group_outlined,
                                      lastNameController,
                                      name2,
                                      'Last Name',
                                      fieldFontSize,
                                    ),
                                    SizedBox(height: spaceBetweenFields),
                                    _buildPhoneField(
                                      context,
                                      state,
                                      fieldFontSize,
                                    ),
                                    SizedBox(height: spaceBetweenFields),
                                    _buildDateField(
                                      context,
                                      state,
                                      fieldFontSize,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: spaceBetweenFields * 2),

                              // أزرار الحفظ والإلغاء
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildActionButton(
                                      "Save",
                                      buttonFontSize,
                                      buttonWidth,
                                      buttonHeight,
                                      isChanged,
                                      () {
                                        BlocProvider.of<ProfileBloc>(
                                          context,
                                        ).add(
                                          EditUserEvent(
                                            fName:
                                                fName ?? state.userModel.fName,
                                            lName:
                                                lName ?? state.userModel.lName,
                                            email:
                                                email ?? state.userModel.email,
                                            phoneNumber:
                                                phoneNumber ??
                                                state.userModel.phoneNumber,
                                            dateOfBirth:
                                                dateOfBirth ??
                                                state.userModel.dateOfBirth,
                                          ),
                                        );
                                        setState(() => isChanged = false);
                                      },
                                    ),
                                    _buildActionButton(
                                      "Cancel",
                                      buttonFontSize,
                                      buttonWidth,
                                      buttonHeight,
                                      true,
                                      () {
                                        BlocProvider.of<ProfileBloc>(
                                          context,
                                        ).add(ShowUserInfoEvent());
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // صورة المستخدم
                    Positioned(
                      top: imagePositionTop,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _pickAndUploadUserImage,
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundImage:
                                userImage != null
                                    ? MemoryImage(userImage!)
                                    : const AssetImage(kDefaultUserImge)
                                        as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is UserInfoErrorState) {
              return Center(
                child: Text(
                  'Something went wrong: ${state.error}',
                  style: TextStyle(fontSize: fieldFontSize),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(color: kPrimaryColor1),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildEditTextField(
    BuildContext context,
    String hintText,
    IconData iconData,
    TextEditingController controller,
    GlobalKey<FormFieldState> key,
    String fieldName,
    double fontSize,
  ) {
    return EditTextField(
      hintText: hintText,
      iconData: iconData,
      controller: controller,
      onChanged: (p0) {
        onFieldChanged(p0);
        if (fieldName == 'First Name') fName = p0;
        if (fieldName == 'Last Name') lName = p0;
      },
      ky: key,
      validatior: (p0) => Validator.validateEmptyField(fieldName, p0),
      fontSize: fontSize,
    );
  }

  Widget _buildPhoneField(
    BuildContext context,
    UserEditedSuccessState state,
    double fontSize,
  ) {
    return PhoneNumberWidget(
      hint: state.userModel.phoneNumber
          .split("number: ")[1]
          .replaceAll(")", ""),
      onchange: (p0) {
        onFieldChanged(p0.toString());
        setState(() {
          phoneNumber = p0.toString();
        });
      },
      dropdownIconColor: kFontColor,
      dropdownTextStyleColor: kFontColor,
      enabledBorderColor: kPrimaryColor1,
      focusedBorderColor: kFontColor,
      hintStyleColor: kFontColor,
      phoneNumberController: _phoneNumberController,
      widget: const Icon(Icons.edit, color: kPrimaryColor1),
      textColor: kFontColor,
    );
  }

  Widget _buildDateField(
    BuildContext context,
    UserEditedSuccessState state,
    double fontSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        onChanged: (p0) {
          onFieldChanged(p0);
          dateOfBirth = p0;
        },
        validator: (p0) {
          if (p0 == null || p0.isEmpty) return "Date of birth is required.";
          final parts = p0.split('/');
          if (parts.length == 3) {
            final formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}";
            final date = DateTime.tryParse(formattedDate);
            if (date == null) return "Invalid date format.";
            return Validator.validateDateOfBirth(date);
          } else {
            return "Invalid date format.";
          }
        },
        controller: birthDateController,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontFamily: kFontRegular,
        ),
        readOnly: true,
        onTap: () async {
          await selectDate(context, _dateController, (selectedDate) {
            dateOfBirth = selectedDate;
            birthDateController.text = selectedDate;
          });
          onFieldChanged(dateOfBirth.toString());
        },
        decoration: InputDecoration(
          hintText: state.userModel.dateOfBirth,
          prefixIcon: const Icon(
            Icons.edit_calendar_rounded,
            color: kPrimaryColor1,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 35.w),
          suffixIcon: const Icon(Icons.edit, color: kPrimaryColor1),
          suffixIconColor: kPrimaryColor1,
          hintStyle: TextStyle(
            color: kFontColor,
            fontSize: fontSize,
            fontFamily: kFontRegular,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kFontColor, width: 1.5.w),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor1, width: 1.5.w),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    double fontSize,
    double width,
    double height,
    bool isEnabled,
    VoidCallback onPressed,
  ) {
    return ButtonWidget(
      name: text,
      fontSize: fontSize,
      onTap: isEnabled ? onPressed : null,
      size: Size(width, height),
      isEnabled: isEnabled,
    );
  }

  Future<void> _pickAndUploadUserImage() async {
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
    try {
      setState(() => _isLoading = true);

      final compressedBytes = await _profileImageService.pickAndCompressImage(
        context,
      );
      if (compressedBytes == null) return;

      _profileImageService.showUploadingDialog(context);

      await _groupService.uploadUserPictureToFirestore(
        userId: user.uid,
        imageBytes: compressedBytes,
      );

      final decrypted = await ProfileImageService().getDecryptedUserImage(
        user.uid,
      );
      if (mounted && decrypted != null) {
        setState(() {
          userImage = decrypted;
          onFieldChanged("p");
        });
      }

      _profileImageService.showSuccessMessage(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isLoading = false);
      }
    }
  }
}
