import 'package:flutter/material.dart';

class RoundImageWidget extends StatelessWidget {
  final String? name;
  final double? width;
  final double? height;
  const RoundImageWidget({
    super.key,
    this.name,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        name!,
        width: width,
        height: height,
        fit: BoxFit.cover, 
      ),
    );
  }
}
