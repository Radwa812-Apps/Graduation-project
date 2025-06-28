import 'dart:developer' as developer;
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';
import '../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';

class MemberGroupInside extends StatefulWidget {
  final String userName;
  final String status;
  final String distance;
  final bool isOwner;
  final String picture;
  final String uid;

  const MemberGroupInside({
    super.key,
    required this.userName,
    required this.status,
    required this.distance,
    this.isOwner = false,
    required this.picture,
    required this.uid,
  });

  @override
  State<MemberGroupInside> createState() => _MemberGroupInsideState();
}

class _MemberGroupInsideState extends State<MemberGroupInside> {
  Uint8List? userImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserImage());
  }

  Future<void> _loadUserImage() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);

      if (widget.uid.isEmpty) {
        developer.log('No UID provided for user: ${widget.userName}');
        return;
      }

      final image = await ProfileImageService().getDecryptedUserImage(
        widget.uid,
      );

      if (image != null && mounted) {
        setState(() => userImage = image);
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error loading user image',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log(
      "Building MemberGroupInside widget for user: ${widget.userName}, UID: ${widget.uid}",
    );
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor1, width: 1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: RoundImageWidget(
              imageBytes: userImage,
              width: 50.w,
              height: 50.h,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.userName,
                        style: TextStyle(
                          color: kFontColor,
                          fontSize: 20.sp,
                          fontFamily: kFontRegular,
                        ),
                      ),
                      if (widget.isOwner) ...[
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: kPrimaryColor1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Owner',
                            style: TextStyle(
                              color: kPrimaryColor1,
                              fontSize: 10.sp,
                              fontFamily: kFontRegular,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    widget.status,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.sp,
                      fontFamily: kFontRegular,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(right: 16.w),
          //   child: Text(
          //     widget.distance,
          //     style: TextStyle(
          //       color: Colors.grey,
          //       fontSize: 15.sp,
          //       fontFamily: kFontRegular,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
