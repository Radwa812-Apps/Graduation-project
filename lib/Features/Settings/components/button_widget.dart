import 'package:flutter/material.dart';
import '../../../core/constants.dart';
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.onTap,
    required this.nameOfButton,
    required this.backgroundColor,
  });

  final VoidCallback onTap;
  final String? nameOfButton;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, 
        foregroundColor: Colors.white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        minimumSize: const Size(70, 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      child: Text(
        nameOfButton!,
        style: const TextStyle(
          fontFamily: kFontRegular,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }
}
