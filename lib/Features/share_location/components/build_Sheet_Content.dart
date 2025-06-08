import 'package:flutter/cupertino.dart';
import 'package:near_me_new_version/Features/group_profile/components/member_group_inside.dart';
import 'package:near_me_new_version/Features/share_location/components/build_search_field.dart';

class BuildSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final String userName; // Placeholder for user name
  final String lastLocatin; // Placeholder for last location
  final String distance; // Placeholder for distance
  const BuildSheetContent({
    required this.scrollController,
    required this.userName,
    required this.lastLocatin,
    required this.distance,
    Key? key,
  }) : super(key: key);

  @override
  _buildSheetContent createState() => _buildSheetContent();
}

class _buildSheetContent extends State<BuildSheetContent> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16), // تعديل البادينج
      children: [
        // حقل البحث
        BuildSearchField(),
        const SizedBox(height: 20),

        // محتوى المجموعة
        MemberGroupInside(
          userName: widget.userName,
          lastLocatin: widget.lastLocatin,
          distance: widget.distance,
        ),
      ],
    );
  }
}
