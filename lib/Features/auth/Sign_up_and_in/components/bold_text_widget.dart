import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants.dart';

class BoldTextWidget extends StatelessWidget {
  final String? name;

  const BoldTextWidget({super.key, this.name});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 50.h,
      ),
      child: Text(name!,
          style: TextStyle(
            fontSize: 40.sp,
            color: Colors.white,
            fontFamily: kFontBold,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
