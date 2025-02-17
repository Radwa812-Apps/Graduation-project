import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants.dart';

class UserProfileInfoWidget extends StatelessWidget {
  final String? info;
  final IconData? iconData;
  final double? size;
  const UserProfileInfoWidget({super.key, this.info, this.iconData, this.size});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.w),
          child: Row(
            children: [
              Icon(
                iconData,
                color: kPrimaryColor1,
                size: size,
              ),
              SizedBox(width: 10.w),
              Text(
                info!,
                style: TextStyle(
                  color: kFontColor,
                  fontFamily: kFontRegular,
                  fontSize: 20.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          height: 1,
          color: kPrimaryColor1,
          width: screenWidth * 0.7.w,
        ),
      ],
    );
  }
}
