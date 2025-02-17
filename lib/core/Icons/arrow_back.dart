import 'package:flutter/material.dart';

class ArrowBack extends StatelessWidget {
  final double top;
  final double left;

  const ArrowBack({super.key, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, 
      child: Padding(
        padding: EdgeInsets.only(top: top, left: left), 
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
