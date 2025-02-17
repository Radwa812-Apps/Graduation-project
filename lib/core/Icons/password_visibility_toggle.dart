import 'package:flutter/material.dart';


class PasswordVisibilityToggle extends StatelessWidget {
  final double top;
  final double left;

  const PasswordVisibilityToggle({
    super.key,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: const Icon(Icons.remove_red_eye_outlined,color:Color.fromRGBO(61, 83, 0, 1),),
    );
  }
}