import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Home/Home/components/search_bar_widget.dart';

import '../../../../core/constants.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final VoidCallback onSearchPressed;
  final VoidCallback onClosePressed;
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final ValueChanged<String> onSearchChanged;

  const HomeAppBar({
    Key? key,
    required this.isSearching,
    required this.onSearchPressed,
    required this.onClosePressed,
    required this.searchController,
    required this.onSearch,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: isSearching
          ? SearchBarWidget(
              controller: searchController,
              onSearch: onSearch,
              onChanged: onSearchChanged,
            )
          : Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                kGreenLogo,
                height: 80,
                width: 80,
              ),
            ),
      actions: isSearching
          ? [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: kPrimaryColor1,
                  size: 33,
                ),
                onPressed: onClosePressed,
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(
                    Icons.search_outlined,
                    color: kPrimaryColor1,
                    size: 33,
                  ),
                  onPressed: onSearchPressed,
                ),
              ),
            ],
      backgroundColor: kBackgroundColor,
      elevation: 0.5,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
