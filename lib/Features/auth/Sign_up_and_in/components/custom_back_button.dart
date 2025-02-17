import 'package:flutter/material.dart';
class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, required this.ontap, required this.icon});
  final Function() ontap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
