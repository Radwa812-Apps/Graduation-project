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
    return LayoutBuilder(
      builder: (context, constraints) {

        final bool isSmallScreen = constraints.maxWidth < 400;
        final bool isMediumScreen =
            constraints.maxWidth >= 400 && constraints.maxWidth < 600;

        final double textSize =
            isSmallScreen
                ? 16.sp
                : isMediumScreen
                ? 18.sp
                : 20.sp;
        final double iconSize =
            isSmallScreen
                ? 20
                : isMediumScreen
                ? 22
                : size ?? 24;
        final double lineWidth = constraints.maxWidth * 0.7;

        final bool showTooltip = iconData == Icons.email_outlined;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20.w : 30.w,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(iconData, color: kPrimaryColor1, size: iconSize),
                  SizedBox(width: isSmallScreen ? 8.w : 10.w),
                  Expanded(
                    child:
                        showTooltip
                            ? Tooltip(
                              message: info ?? '',
                              child: _buildText(info, textSize),
                            )
                            : _buildText(info, textSize),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 3.h : 5.h),
            Container(
              height: 0.5,
              color: kPrimaryColor1.withOpacity(0.5),
              width: lineWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildText(String? text, double fontSize) {
    return Text(
      text ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: TextStyle(
        color: kFontColor,
        fontFamily: kFontRegular,
        fontSize: fontSize,
        height: 1.2, 
      ),
    );
  }
}
