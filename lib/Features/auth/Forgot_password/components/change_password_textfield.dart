import 'package:flutter/material.dart';
import 'package:near_me_new_version/core/font_style.dart';

import '../../../../core/constants.dart';
class ChangePasswordTextfield extends StatelessWidget {
  final String textHint;
  final Widget leftIcon;
  final Widget rightIcon;
  final TextEditingController controller;
  final bool isPasswordVisible;

  const ChangePasswordTextfield({
    Key? key,
    required this.textHint,
    required this.leftIcon,
    required this.rightIcon,
    required this.controller,
    required this.isPasswordVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        hintText: textHint,
        hintStyle: TextStyles.forgotPasswordText,
        prefixIcon: leftIcon,
        suffixIcon: rightIcon,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: kPrimaryColor1,
            width: 0.25,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: kPrimaryColor1,
            width: 0.5,
          ),
        ),
        isDense: true,
      ),
      style: TextStyles.forgotPasswordText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'You should enter $textHint';
        }
        return null;
      },
    );
  }
}
