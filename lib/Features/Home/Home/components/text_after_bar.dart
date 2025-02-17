import 'package:flutter/material.dart';

import '../../../../core/constants.dart';


class TextAfterBar extends StatelessWidget {
  final String? name;
  final Color? color;
  const TextAfterBar({super.key, this.name, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      name!,
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontFamily: kFontBold,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
