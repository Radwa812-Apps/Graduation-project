import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../core/constants.dart';
import '../../../../core/services/validator.dart';

class PhoneNumberWidget extends StatelessWidget {
  final TextEditingController phoneNumberController;
  final Function(PhoneNumber) onchange;
  final Color dropdownTextStyleColor;
  final Color dropdownIconColor;
  final Color hintStyleColor;
  final Color focusedBorderColor;
  final Color enabledBorderColor;
  final Widget? widget;
  final Color textColor;
  final String hint;
  final double? fontSize; 

  const PhoneNumberWidget({
    super.key,
    required this.onchange,
    required this.dropdownTextStyleColor,
    required this.dropdownIconColor,
    required this.hintStyleColor,
    required this.focusedBorderColor,
    required this.enabledBorderColor,
    required this.hint,
    required this.phoneNumberController,
    required this.textColor,
    this.widget,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد حجم الشاشة
        final bool isSmallScreen = constraints.maxWidth < 400;
        final bool isMediumScreen =
            constraints.maxWidth >= 400 && constraints.maxWidth < 600;

        // ضبط الأحجام بشكل ديناميكي
        final double textSize =
            fontSize ??
            (isSmallScreen
                ? 14.sp
                : isMediumScreen
                ? 15.sp
                : 16.sp);
        final double paddingHorizontal = isSmallScreen ? 15.w : 20.w;
        final double borderWidth = isSmallScreen ? 1.0.w : 1.5.w;
        final double iconSize = isSmallScreen ? 20.sp : 22.sp;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          child: IntlPhoneField(
            controller: phoneNumberController,
            validator: (p0) => Validator.validatePhoneNumber(p0),
            dropdownTextStyle: TextStyle(
              color: dropdownTextStyleColor,
              fontSize: textSize,
            ),
            keyboardType: TextInputType.phone,
            dropdownIcon: Icon(
              Icons.arrow_drop_down,
              color: dropdownIconColor,
              size: iconSize,
            ),
            style: TextStyle(color: textColor, fontSize: textSize),
            decoration: InputDecoration(
              hintText: hint,
              labelStyle: TextStyle(color: textColor, fontSize: textSize),
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: textColor,
                size: iconSize,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: isSmallScreen ? 30.w : 35.w,
              ),
              suffixIcon: widget,
              suffixIconColor: focusedBorderColor,
              hintStyle: TextStyle(
                color: hintStyleColor,
                fontSize: textSize,
                fontFamily: kFontRegular,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: focusedBorderColor,
                  width: borderWidth,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: enabledBorderColor,
                  width: borderWidth,
                ),
              ),
            ),
            initialCountryCode: 'EG',
            onSaved: (phone) => Validator.validatePhoneNumber(phone),
            onChanged: onchange,
          ),
        );
      },
    );
  }
}
