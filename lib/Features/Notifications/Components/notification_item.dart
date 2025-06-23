import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants.dart';

class NotificationItem extends StatelessWidget {
  final String? title;
  final String? name;
  final String message;
  final String time;
  final VoidCallback? onPressed;
  final bool showForwardIcon;
  const NotificationItem({
    Key? key,
    this.title,
    this.name,
    required this.message,
    required this.time,
    this.onPressed,
    this.showForwardIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 300.w,
        height: 90.h,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.w),
              topRight: Radius.circular(20.w),
              bottomLeft: Radius.circular(10.w),
              bottomRight: Radius.circular(10.w),
            ),
            color: Color.fromRGBO(181, 158, 90, 0.675).withOpacity(0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10.0,
                spreadRadius: 2.0,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.0,
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
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans-Regular',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (title != null) SizedBox(height: 1.h),
                    Row(
                      children: [
                        if (name != null)
                          Text(
                            '$name:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'OpenSans-Regular',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        if (name != null) SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
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
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: kPrimaryColor1,
                        size: 16,
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
      ),
    );
  }
}
