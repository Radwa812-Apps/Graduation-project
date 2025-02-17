import 'package:flutter/material.dart';
import '../../../core/constants.dart';
class SplitBetweenFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: (10.0)),
      child: Container(
        width: screenWidth * .01,
        height: 1,
        color: kPrimaryColor1.withOpacity(.20),
      ),
    );
  }
}
