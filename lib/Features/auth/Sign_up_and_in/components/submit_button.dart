import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants.dart';

class SubmitButton extends StatelessWidget {
  final String? name;
  final void Function()? onTap;

  const SubmitButton({super.key, this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 51.h,
          width: 200.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: kSpecialColor,
          ),
          child: Center(
            child: Text(
              name!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 29.sp,
                fontWeight: FontWeight.bold,
                fontFamily: kFontSemiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
