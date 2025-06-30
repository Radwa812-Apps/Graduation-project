import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/chat_group/components/three_dots_manu.dart';
import '../../Notifications/Components/search_icon.dart';
import '../../../core/constants.dart';
import '../../../core/font_style.dart';

class HeaderGroupChat extends StatefulWidget {
  final String title;
  final Widget backArrow;
  final VoidCallback? onBackPressed;
  final bool showCircleAvatar;
  final String? circleAvatarImage;
  final VoidCallback onClearChatPressed;
  final String image;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onGroupInfoPressed;
  final Uint8List? circleAvatarImageBytes;

  const HeaderGroupChat({
    Key? key,
    required this.title,
    required this.backArrow,
    this.onBackPressed,
    this.showCircleAvatar = true,
    this.circleAvatarImage,
    required this.onClearChatPressed,
    required this.image,
    this.onSearchChanged,
    this.onGroupInfoPressed,
    required this.circleAvatarImageBytes,
  }) : super(key: key);

  @override
  _HeaderChatState createState() => _HeaderChatState();
}

class _HeaderChatState extends State<HeaderGroupChat> {
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
      widget.onSearchChanged?.call('');
    });
  }

  void _onSearch(String query) {
    widget.onSearchChanged?.call(query);
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
          child:
              _isSearchVisible
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
                        onTap:
                            widget.onBackPressed ??
                            () {
                              Navigator.pop(context);
                            },
                        child: widget.backArrow,
                      ),
                      const SizedBox(width: 10),
                      if (widget.showCircleAvatar)
                        GestureDetector(
                          onTap: widget.onGroupInfoPressed,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                widget.circleAvatarImageBytes != null
                                    ? MemoryImage(
                                      widget.circleAvatarImageBytes!,
                                    )
                                    : const AssetImage(
                                          "assets/images/group.jpg",
                                        )
                                        as ImageProvider,
                          ),
                        ),
                      if (widget.showCircleAvatar) const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onGroupInfoPressed,
                          child: Text(
                            widget.title,
                            style: TextStyles.NotificationsTilteText.copyWith(
                              fontSize: 16,
                            ), // Smaller text size
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
