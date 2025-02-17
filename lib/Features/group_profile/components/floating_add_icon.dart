import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_profile_screen.dart';
import '../../../core/constants.dart';
class FloatingAddIcon extends StatelessWidget {
  const FloatingAddIcon({
    super.key,
    required this.screenWidth,
    required this.isCheckboxSelected,
  });

  final double screenWidth;
  final bool isCheckboxSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 40, left: screenWidth * .75),
      child: GestureDetector(
        onTap: isCheckboxSelected
            ? () {
                Navigator.pushNamed(
                    context, GroupProfileScreen.groupProfileScreenKey);
              }
            : null,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCheckboxSelected ? kPrimaryColor1 : Colors.grey,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.done,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
