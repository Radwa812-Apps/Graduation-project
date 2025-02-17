import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../core/constants.dart';
import '../../../../core/services/validator.dart';

class PhoneNumberWidget extends StatelessWidget {
  PhoneNumberWidget(
      {super.key,
      required this.onchange,
      required this.dropdownTextStyleColor,
      required this.dropdownIconColor,
      required this.hintStyleColor,
      required this.focusedBorderColor,
      required this.enabledBorderColor,
      required this.hint,
      required this.phoneNumberController,
      required this.textColor,
      required this.widget});
  final TextEditingController phoneNumberController;
  final Function(PhoneNumber) onchange;
  final Color dropdownTextStyleColor;
  final Color dropdownIconColor;
  final Color hintStyleColor;
  final Color focusedBorderColor;
  final Color enabledBorderColor;
  Widget? widget;
  final Color textColor;

  final String hint;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: IntlPhoneField(
          controller: phoneNumberController,
          validator: ((p0) {
            return Validator.validatePhoneNumber(p0);
          }),
          dropdownTextStyle: TextStyle(color: dropdownTextStyleColor),
          keyboardType: TextInputType.phone,
          dropdownIcon: Icon(
            Icons.arrow_drop_down,
            color: dropdownIconColor,
          ),
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            labelStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Colors.white,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 35,
            ),
            suffixIcon: widget,
            suffixIconColor: focusedBorderColor,
            hintStyle: TextStyle(
              color: hintStyleColor,
              fontSize: 20.sp,
              fontFamily: kFontRegular,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: focusedBorderColor,
                width: 1.5.w,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: enabledBorderColor,
                width: 1.5.w,
              ),
            ),
          ),
          initialCountryCode: 'EG',
          onSaved: (phone) {
            Validator.validatePhoneNumber(phone);
          },
          onChanged: onchange),
    );
  }
}
