import 'package:flutter/material.dart';

class CircleIndicator extends StatelessWidget {
  final Widget child;

  const CircleIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 43,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(171, 186, 124, 1),
        borderRadius: BorderRadius.all(
          Radius.elliptical(46, 43),
        ),
      ),
      child: Center(child: child), 
    );
  }
}