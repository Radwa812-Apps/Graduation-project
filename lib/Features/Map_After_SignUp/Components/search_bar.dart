import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class Search extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose; 

  const Search({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onChanged,
    required this.onClose, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        cursorColor: Colors.white,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: const Icon(Icons.arrow_back, color: gray),
            onPressed: onClose, 
          ),
          hintText: 'Search...',
          hintStyle: const TextStyle(
            color: gray,
            fontFamily: 'OpenSans-Regular',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.green,
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