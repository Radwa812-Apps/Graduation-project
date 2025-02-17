import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Notifications/Components/search_icon.dart';
import '../../../core/constants.dart';
import '../../../core/font_style.dart' show TextStyles;
class HeaderNotifications extends StatefulWidget {
  final String title;
  final Widget? backArrow;
  final VoidCallback? onBackPressed;
  final bool showCircleAvatar;
  final String? circleAvatarImage;
  final String image;
  const HeaderNotifications({
    Key? key,
    required this.title,
    this.backArrow,
    this.onBackPressed,
    this.showCircleAvatar = true,
    this.circleAvatarImage,
    required this.image,
  }) : super(key: key);

  @override
  _HeaderNotificationsState createState() => _HeaderNotificationsState();
}

class _HeaderNotificationsState extends State<HeaderNotifications> {
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
    });
  }

  @override
  Widget build(BuildContext context) {
     Widget defaultBackArrow = Icon(
      Icons.arrow_back_ios,
      color: kPrimaryColor1,
      size: 25.sp,
    );

    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        color: kPrimaryColor1.withOpacity(0.20),
      ),
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _showSearchBar
              ? SearchIcon(
                  controller: _searchController,
                  onSearch: () {},
                  onChanged: (value) {},
                  onClose: _toggleSearchBar,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.backArrow != null ||
                        widget.onBackPressed != null)
                      GestureDetector(
                        onTap: widget.onBackPressed ??
                            () {
                              Navigator.pop(context);
                            },
                        child: widget.backArrow ?? defaultBackArrow,
                      ),
                     SizedBox(width: 10.w),
                    if (widget.showCircleAvatar)
                      CircleAvatar(
                        backgroundImage: widget.circleAvatarImage != null
                            ? AssetImage(widget.circleAvatarImage!)
                            : AssetImage(widget.image),
                        radius: 20,
                      ),
                    if (widget.showCircleAvatar)  SizedBox(width: 10.w),
                    Text(
                      widget.title,
                      style: TextStyles.NotificationsTilteText,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          icon:  Icon(
                            Icons.search,
                            color: kPrimaryColor1,
                            size: 30.sp,
                          ),
                          onPressed: _toggleSearchBar,
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
