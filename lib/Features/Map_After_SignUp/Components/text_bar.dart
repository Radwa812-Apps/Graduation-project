import 'package:flutter/material.dart';

import '../../../core/constants.dart';

class TextBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const TextBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.7, 
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical:1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter name...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'OpenSans-Bold',
                  fontWeight: FontWeight.w700,
                  color:textColor,
                ),
                autofocus: true,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onSubmitted,
            ),
          ],
        ),
      ),
    );
  }
}
