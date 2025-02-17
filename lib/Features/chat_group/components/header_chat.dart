import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/chat_group/components/three_dots_manu.dart';

import '../../../core/constants.dart';
import '../../../core/font_style.dart';
import '../../Notifications/Components/search_icon.dart';

class HeaderChat extends StatefulWidget {
  final String title;
  final Widget backArrow;
  final VoidCallback? onBackPressed;
  final bool showCircleAvatar;
  final String? circleAvatarImage;
  final VoidCallback onClearChatPressed;
  final String image;

  const HeaderChat({
    Key? key,
    required this.title,
    required this.backArrow,
    this.onBackPressed,
    this.showCircleAvatar = true,
    this.circleAvatarImage,
    required this.onClearChatPressed, required this.image,
  }) : super(key: key);

  @override
  _HeaderChatState createState() => _HeaderChatState();
}

class _HeaderChatState extends State<HeaderChat> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  void _onSearchPressed() {
    setState(() {
      _isSearchVisible = true;
    });
  }

  void _onCloseSearch() {
    setState(() {
      _isSearchVisible = false;
      _searchController.clear();
    });
  }

  void _onSearch(String query) {
    print("Searching for: $query");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        color: kPrimaryColor1.withOpacity(0.20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _isSearchVisible
              ? SearchIcon(
                  controller: _searchController,
                  onSearch: () {
                    _onSearch(_searchController.text);
                  },
                  onChanged: _onSearch,
                  onClose: _onCloseSearch,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: widget.onBackPressed ??
                          () {
                            Navigator.pop(context);
                          },
                      child: widget.backArrow,
                    ),
                    const SizedBox(width: 10),
                    if (widget.showCircleAvatar)
                      CircleAvatar(
                        backgroundImage: widget.circleAvatarImage != null
                            ? AssetImage(widget.circleAvatarImage!)
                            :  AssetImage(widget.image),
                        radius: 20,
                      ),
                    if (widget.showCircleAvatar) const SizedBox(width: 10),
                    Text(
                      widget.title,
                      style: TextStyles.NotificationsTilteText,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        ThreeDotMenu(
                          onMutePressed: () {
                            print('Mute pressed');
                          },
                          onClearChatPressed: widget.onClearChatPressed,
                          onSearchPressed: _onSearchPressed,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
