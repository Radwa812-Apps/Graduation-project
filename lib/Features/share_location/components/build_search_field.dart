import 'package:flutter/material.dart';
import 'package:near_me_new_version/core/constants.dart';

class BuildSearchField extends StatelessWidget {
  final TextEditingController controller;

  const BuildSearchField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search...',
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: Icon(Icons.search, color: kPrimaryColor1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      
      ],
    );
  }
}
