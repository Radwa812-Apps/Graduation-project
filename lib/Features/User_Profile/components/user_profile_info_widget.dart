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

    
    final bool showTooltip = iconData == Icons.email_outlined;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.w, right: 20.w),
          child: Row(
            children: [
              Icon(iconData, color: kPrimaryColor1, size: size),
              SizedBox(width: 10.w),
              Expanded(
                child:
                    showTooltip
                        ? Tooltip(
                          message: info ?? '',
                          child: Text(
                            info ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              color: kFontColor,
                              fontFamily: kFontRegular,
                              fontSize: 20.sp,
                            ),
                          ),
                        )
                        : Text(
                          info ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: kFontColor,
                            fontFamily: kFontRegular,
                            fontSize: 20.sp,
                          ),
                        ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(height: 1, color: kPrimaryColor1, width: screenWidth * 0.7.w),
      ],
    );
  }
}
