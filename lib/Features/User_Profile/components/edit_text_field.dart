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
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
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
            padding: EdgeInsets.only(right: 12.w),
            child: Icon(
              iconData,
              color: kPrimaryColor1,
              size: 22.sp,
            ),
          ),
          suffixIcon: Icon(
            Icons.edit,
            color: kPrimaryColor1,
            size: 22.sp,
          ),
          hintStyle: TextStyle(
            fontSize: 20.sp,
            fontFamily: kFontRegular,
            color: kFontColor,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kPrimaryColor1,
              width: 1.5.w,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: kPrimaryColor1,
              width: 1.5.w,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 20.sp,
          fontFamily: kFontRegular,
          color: kFontColor,
        ),
      ),
    );
  }
}
