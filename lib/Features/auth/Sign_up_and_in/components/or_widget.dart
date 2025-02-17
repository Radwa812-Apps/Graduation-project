import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants.dart';

class ORWediget extends StatelessWidget {
  final double? oRsize;
  final double? lineWidth;

  const ORWediget({super.key, this.oRsize, this.lineWidth});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 1.h,
          color: Colors.white,
          width: lineWidth,
        ),
        SizedBox(
          width: 10.w,
        ),
        Text(
          'OR',
          style: TextStyle(
            color: Colors.white,
            fontSize: oRsize,
            fontFamily: kFontRegular,
          ),
        ),
        SizedBox(
          width: 10.w,
        ),
        Container(
          height: 1.h,
          color: Colors.white,
          width: lineWidth,
        ),
      ],
    );
  }
}
