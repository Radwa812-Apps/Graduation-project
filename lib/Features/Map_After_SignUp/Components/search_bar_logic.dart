import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/search_bar.dart';

class SearchBarLogic extends StatelessWidget {
  final bool isSearchVisible;
  final VoidCallback onSearchPressed;
  final VoidCallback onCloseSearch;
  final TextEditingController searchController;

  const SearchBarLogic({
    Key? key,
    required this.isSearchVisible,
    required this.onSearchPressed,
    required this.onCloseSearch,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight, 
      child: Padding(
        padding: const EdgeInsets.only(top: 40, right: 20),
        child: isSearchVisible
            ? Search(
                controller: searchController,
                onSearch: () {
                  print("Searching for: ${searchController.text}");
                },
                onChanged: (value) {
                  print("Search input: $value");
                },
                onClose: onCloseSearch,
              )
            : GestureDetector(
                onTap: onSearchPressed,
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
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.search,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
