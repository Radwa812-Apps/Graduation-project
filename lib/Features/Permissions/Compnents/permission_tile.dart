import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants.dart';class PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool switchValue;
  final Function(bool) onChanged;

  const PermissionTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30.sp,
            color: kPrimaryColor1,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'OpenSans-Regular',
                      fontWeight: FontWeight.w400,
                      color: textColor),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: gray,
                    fontFamily: 'OpenSans-Italic',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9.sp,
            child: Switch(
              value: switchValue,
              onChanged: onChanged,
              activeColor: kPrimaryColor1,
            ),
          ),
        ],
      ),
    );
  }
}
