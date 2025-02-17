import 'package:flutter/material.dart';

import '../../../../core/constants.dart';

class IconButtonWidegt extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final void Function()? onPressed;

  const IconButtonWidegt({super.key, this.icon, this.onPressed, this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon!,
        color: kPrimaryColor1,
        size: size,
      ),
    );
  }
}
