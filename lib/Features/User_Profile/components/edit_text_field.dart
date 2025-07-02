import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants.dart';

class EditTextField extends StatelessWidget {
  final String? hintText;
  final IconData? iconData;
  final bool? readOnly;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?) validatior;
  final GlobalKey<FormFieldState> ky;
  final double? fontSize; 

  const EditTextField({
    super.key,
    required this.hintText,
    required this.iconData,
    this.readOnly = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    required this.ky,
    required this.validatior,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 400;
        final bool isMediumScreen =
            constraints.maxWidth >= 400 && constraints.maxWidth < 600;

        final double textSize =
            fontSize ??
            (isSmallScreen
                ? 16.sp
                : isMediumScreen
                ? 18.sp
                : 20.sp);
        final double iconSize =
            isSmallScreen
                ? 20.sp
                : isMediumScreen
                ? 22.sp
                : 24.sp;
        final double borderWidth = isSmallScreen ? 1.0.w : 1.5.w;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 10.w : 15.w,
          ),
          child: TextFormField(
            key: ky,
            validator: validatior,
            controller: controller,
            readOnly: readOnly!,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: isSmallScreen ? 8.w : 12.w),
                child: Icon(iconData, color: kPrimaryColor1, size: iconSize),
              ),
              suffixIcon: Icon(
                Icons.edit,
                color: kPrimaryColor1,
                size: iconSize,
              ),
              hintStyle: TextStyle(
                fontSize: textSize,
                fontFamily: kFontRegular,
                color: kFontColor,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: kPrimaryColor1,
                  width: borderWidth,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: kPrimaryColor1,
                  width: borderWidth,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: textSize,
              fontFamily: kFontRegular,
              color: kFontColor,
              height: 1.2, 
            ),
          ),
        );
      },
    );
  }
}
