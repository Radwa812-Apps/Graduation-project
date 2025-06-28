import 'package:flutter/material.dart';

class SearchInMap extends StatelessWidget {
  const SearchInMap({super.key, required this.onChanged});
final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged:onChanged ,
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: (() {}),
            icon: const Icon(Icons.search, color: Colors.grey),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
