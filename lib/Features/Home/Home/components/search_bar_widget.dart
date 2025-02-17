import 'package:flutter/material.dart';

import '../../../../core/constants.dart';


class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search here...',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: kFontRegular,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: kPrimaryColor1,
              ),
              onPressed: onSearch,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
 