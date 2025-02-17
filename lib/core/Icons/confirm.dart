import 'package:flutter/material.dart';


class Confirm extends StatelessWidget {
  final double top;
  final double left;

  const Confirm({
    super.key,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: const Icon(Icons.check,color:Color.fromRGBO(61, 83, 0, 1),),
    );
  }
}

 