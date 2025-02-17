import 'package:flutter/material.dart';
import 'package:near_me_new_version/core/constants.dart' show kSpecialColor;

class SkipNextButtons extends StatelessWidget {
  final VoidCallback onSkipPressed;
  final VoidCallback onNextPressed;

  const SkipNextButtons({
    Key? key,
    required this.onSkipPressed,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onSkipPressed,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.skip_next_outlined,
                    size: 30, color: kSpecialColor),
              ),
            ),
          ),
          GestureDetector(
            onTap: onNextPressed,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Padding(
                padding:  EdgeInsets.all(10),
                child: Icon(
                  Icons.next_plan_outlined,
                  size: 30,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}