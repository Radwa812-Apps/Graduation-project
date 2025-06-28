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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // final GlobalKey<FormState> formKey = GlobalKey();

    ImageProvider imageProvider = const AssetImage(kDefaultUserImge);
    if (userImage != null) {
      imageProvider = MemoryImage(userImage!);
    }
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is UserEditedSuccessState) {
          return Center(
            // child: Form(
            //   key: formKey,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: widget.paddingTopContainer),
                  child: Container(
                    width: screenWidth * 0.80.w,
                    height: screenHeight * 0.72.h,
                    decoration: BoxDecoration(
                      color: kPrimaryColor1.withOpacity(.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 70.h),
                          const Text(
                            'Edit Your Profile',
                            style: TextStyle(
                              color: kFontColor,
                              fontFamily: kFontBold,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.06.w),

                          // First Name Field
                          EditTextField(
                            hintText: state.userModel.fName,
                            iconData: Icons.person_outlined,
                            controller: firstNameController,
                            onChanged: ((p0) {
                              onFieldChanged(p0);
                              fName = p0;
                            }),
                            ky: name,
                            validatior: ((p0) {
                              Validator.validateEmptyField('First Nmae', p0);
                              // return "Fist Name should not contain any spaces.";
                            }),
                          ),

                          SizedBox(height: widget.spaceWithRows),

                          // Last Name Field
                          EditTextField(
                            hintText: state.userModel.lName,
                            iconData: Icons.group_outlined,
                            controller: lastNameController,
                            onChanged: ((p0) {
                              onFieldChanged(p0);
                              lName = p0;
                            }),
                            ky: name2,
                            validatior: ((p0) {
                              Validator.validateEmptyField('First Nmae', p0);
                            }),
                          ),
                          SizedBox(height: widget.spaceWithRows),

                          // Phone Number Field
                          PhoneNumberWidget(
                            hint: state.userModel.phoneNumber
                                .split("number: ")[1]
                                .replaceAll(")", ""),
                            onchange: ((p0) {
                              onFieldChanged(p0.toString());
                              setState(() {
                                phoneNumber = p0.toString();
                              });
                            }),
                            dropdownIconColor: kFontColor,
                            dropdownTextStyleColor: kFontColor,
                            enabledBorderColor: kPrimaryColor1,
                            focusedBorderColor: kFontColor,
                            hintStyleColor: kFontColor,
                            phoneNumberController: _phoneNumberController,
                            widget: const Icon(
                              Icons.edit,
                              color: kPrimaryColor1,
                            ),
                            textColor: kFontColor,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: TextFormField(
                              onChanged: ((p0) {
                                onFieldChanged(p0);
                                dateOfBirth = p0;
                              }),
                              validator: ((p0) {
                                if (p0 == null || p0.isEmpty) {
                                  return "Date of birth is required.";
                                }
                                final parts = p0.split('/');
                                if (parts.length == 3) {
                                  final formattedDate =
                                      "${parts[2]}-${parts[1]}-${parts[0]}";
                                  final date = DateTime.tryParse(formattedDate);
                                  if (date == null) {
                                    return "Invalid date format.";
                                  }
                                  return Validator.validateDateOfBirth(date);
                                } else {
                                  return "Invalid date format.";
                                }
                              }),
                              controller: birthDateController,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontFamily: kFontRegular,
                              ),
                              readOnly: true,
                              onTap: (() async {
                                await selectDate(context, _dateController, (
                                  selectedDate,
                                ) {
                                  dateOfBirth = selectedDate;
                                  birthDateController.text = selectedDate;
                                });
                                onFieldChanged(dateOfBirth.toString());
                              }),
                              decoration: InputDecoration(
                                hintText: state.userModel.dateOfBirth,
                                prefixIcon: const Icon(
                                  Icons.edit_calendar_rounded,
                                  color: kPrimaryColor1,
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 35.w,
                                ),
                                suffixIcon: const Icon(
                                  Icons.edit,
                                  color: kPrimaryColor1,
                                ),
                                suffixIconColor: kPrimaryColor1,
                                hintStyle: TextStyle(
                                  color: kFontColor,
                                  fontSize: 20.sp,
                                  fontFamily: kFontRegular,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kFontColor,
                                    width: 1.5.w,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kPrimaryColor1,
                                    width: 1.5.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: widget.spaceWithRows),
                          SizedBox(height: screenWidth * 0.1.w),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonWidget(
                                name: "Save",
                                fontSize: 20.sp,
                                onTap:
                                    isChanged
                                        ? () {
                                          // if (formKey.currentState!.validate()) {
                                          BlocProvider.of<ProfileBloc>(
                                            context,
                                          ).add(
                                            EditUserEvent(
                                              fName:
                                                  fName ??
                                                  state.userModel.fName,
                                              lName:
                                                  lName ??
                                                  state.userModel.lName,
                                              email:
                                                  email ??
                                                  state.userModel.email,
                                              phoneNumber:
                                                  phoneNumber ??
                                                  state.userModel.phoneNumber,
                                              dateOfBirth:
                                                  dateOfBirth ??
                                                  state.userModel.dateOfBirth,
                                            ),
                                          );
                                          setState(() {
                                            isChanged = false;
                                          });
                                          // }
                                        }
                                        : null,
                                size: Size(100, 65),
                                isEnabled: isChanged,
                              ),
                              SizedBox(width: 70.w),
                              ButtonWidget(
                                name: "Cancel",
                                fontSize: 20,
                                onTap: () {
                                  BlocProvider.of<ProfileBloc>(
                                    context,
                                  ).add(ShowUserInfoEvent());
                                  Navigator.pop(context);
                                },
                                size: const Size(100, 65),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: widget.imagePositionTop,
                  left: 0,
                  right: 0,

                  child: Center(
                    child: GestureDetector(
                      onTap: _pickAndUploadUserImage,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: imageProvider,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is UserInfoErrorState) {
          return Center(child: Text('Something went wrong: ${state.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
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
