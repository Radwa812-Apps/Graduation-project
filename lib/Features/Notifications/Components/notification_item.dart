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
        height: 100.h,
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
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          color: kPrimaryColor1,
                          fontFamily: 'OpenSans-Bold',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (title != null) SizedBox(height: 7.h),
                    Expanded(
                      child: Row(
                        children: [
                          if (name != null)
                            CircleAvatar(
                              radius: 15.w,
                              backgroundImage: AssetImage(
                                'assets/images/user.jpg',
                              ),
                              backgroundColor: Colors.grey[300],
                            ),
                          if (name != null) SizedBox(width: 10.w),

                          Flexible(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 95, 94, 94),
                                fontFamily: 'OpenSans-Regular',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (showForwardIcon) SizedBox(height: 20.h),

                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor1,
                      size: 16,
                    ),
                    onPressed: onPressed,
                  ),

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
