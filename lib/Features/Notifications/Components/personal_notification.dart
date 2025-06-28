import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants.dart';

class PersonalNotificationItem extends StatelessWidget {
  final String message;
  final String time;
  final VoidCallback? onPressed;
  final bool showForwardIcon;
  const PersonalNotificationItem({
    Key? key,
    required this.message,
    required this.time,
    this.onPressed,
    this.showForwardIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.w,
      height: 86.h,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 172, 220, 170).withOpacity(0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 95, 94, 94),
                            fontFamily: 'OpenSans-Regular',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showForwardIcon)
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor1,
                      size: 16.sp,
                    ),
                    onPressed: () {},
                  ),
                SizedBox(height: 5.h),
                Text(
                  time,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'OpenSans-Regular',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
