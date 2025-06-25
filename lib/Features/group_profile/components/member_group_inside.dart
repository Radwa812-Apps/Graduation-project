import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';
import '../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';

class MemberGroupInside extends StatefulWidget {
  const MemberGroupInside({
    super.key,
    required this.userName,
    required this.lastLocatin,
    required this.distance,
    this.isOwner = false,
    required this.picture,
    required this.uid,
  });

  final String userName;
  final String lastLocatin;
  final String distance;
  final bool isOwner;
  final String picture;
  final String uid;

  @override
  State<MemberGroupInside> createState() => _MemberGroupInsideState();
}



class _MemberGroupInsideState extends State<MemberGroupInside> {
  Uint8List? userImage;
  @override
  void initState() {
    super.initState();
    _loadUserImage();
  }
  void _loadUserImage() async {
    log("for uid: ${widget.uid}");
    if (widget.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not authenticated"),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    if (widget.uid != null) {
      final image = await ProfileImageService().getDecryptedUserImage(widget.uid);
      if (image != null && mounted) {
        setState(() {
          userImage = image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log("building MemberGroupInside for user: ${widget.userName}");
    log("userImage Length: ${userImage?.length ?? 0}");
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor1, width: 1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: kBackgroundColor,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: RoundImageWidget(
              imageBytes: userImage,
              //name: kDefaultUserImge,
              width: 50,
              height: 50,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: kFontColor,
                        fontSize: 20,
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
                const SizedBox(height: 1),
                Text(
                  widget.lastLocatin,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontFamily: kFontRegular,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              widget.distance,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontFamily: kFontRegular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
