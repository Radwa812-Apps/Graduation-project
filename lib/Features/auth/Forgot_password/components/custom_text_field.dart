import 'package:flutter/material.dart';

import '../../../../core/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode currentFocus;
  final FocusNode? nextFocus;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.currentFocus,
    this.nextFocus,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 40,
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color.fromRGBO(61, 83, 0, 1),
          fontFamily: 'Open Sans',
          fontSize: 24,
          fontWeight: FontWeight.normal,
        ),
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(
            color: kPrimaryColor1,
            fontFamily: 'Open Sans',
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
          counterText: '',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          alignLabelWithHint: true,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && nextFocus != null) {
            nextFocus!.requestFocus();
          }
        },
      ),
    );
  }
}
