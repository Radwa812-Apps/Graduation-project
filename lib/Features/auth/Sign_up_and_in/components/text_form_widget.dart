import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants.dart';

class TextFormFieldWidget extends StatefulWidget {
  final String? hint;
  final Icon? prefixIcon;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool isBirthDate;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final String? Function(String?) validatior;
  final Function(String) onchange;
  final Color lineColor;
  final Color hintColor;
  final Color lineFocusColor;
  final IconData? editIcon;
  const TextFormFieldWidget({
    super.key,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.isPassword = false,
    this.isBirthDate = false,
    this.controller,
    this.onTap,
    required this.validatior,
    required this.onchange,
    required this.lineColor,
    required this.hintColor,
    required this.lineFocusColor,
    required this.editIcon,
  });

  @override
  _TextFormFieldWidgetState createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  bool _obscureText = true;
  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
      ),
      child: TextFormField(
        onChanged: widget.onchange,
        validator: widget.validatior,
        controller: widget.controller,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontFamily: kFontRegular,
        ),
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? _obscureText : false,
        readOnly: widget.isBirthDate,
        onTap: widget.isBirthDate ? widget.onTap : null,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: BoxConstraints(
            minWidth: 35.w,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          hintStyle: TextStyle(
            color: widget.hintColor,
            fontSize: 20.sp,
            fontFamily: kFontRegular,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.lineFocusColor,
              width: 1.5.w,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.lineColor,
              width: 1.5.w,
            ),
          ),
        ),
      ),
    );
  }
}
