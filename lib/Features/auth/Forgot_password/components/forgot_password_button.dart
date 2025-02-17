import 'package:flutter/material.dart';

import '../../../../core/font_style.dart';

class ForgotPasswordButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;

  const ForgotPasswordButton({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            color: const Color.fromRGBO(255, 212, 73, 1),
          ),
          child: Center(
            child: Text(
              buttonText,
              textAlign: TextAlign.center,
              style: TextStyles.forgotPasswordButtonText,
            ),
          ),
        ),
      ),
    );
  }
}