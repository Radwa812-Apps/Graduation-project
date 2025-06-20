/*import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/share_location/components/build_Sheet_Content.dart';

class BuildBottomSheetWithAvatar extends StatefulWidget {
  final String avatarUrl;
  final String userName;
  final String lastLocatin;
  final String distance;
  
  BuildBottomSheetWithAvatar({
    required this.avatarUrl,
    required this.userName,
    required this.lastLocatin,
    required this.distance,
  Key? key,

  });

  @override
  _BuildBottomSheetWithAvatarState createState() => _BuildBottomSheetWithAvatarState();
}
class _BuildBottomSheetWithAvatarState extends State<BuildBottomSheetWithAvatar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),

          child: DraggableScrollableSheet(
            initialChildSize: 0.53,
            minChildSize: 0.04,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.1, 0.53, 0.85],
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: BuildSheetContent(
                  scrollController: scrollController,
                  userName: widget.userName,
                  lastLocatin: widget.lastLocatin,
                  distance: widget.distance,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

*/
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/share_location/components/build_Sheet_Content.dart';

class BuildBottomSheetWithAvatar extends StatefulWidget {
  final String avatarUrl;
  final String groupId;
  final List<Map<String, dynamic>> groupMembers;

  const BuildBottomSheetWithAvatar({
    required this.avatarUrl,
    required this.groupId,
    required this.groupMembers,
    Key? key,
  }) : super(key: key);

  @override
  _BuildBottomSheetWithAvatarState createState() => _BuildBottomSheetWithAvatarState();
}

class _BuildBottomSheetWithAvatarState extends State<BuildBottomSheetWithAvatar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: DraggableScrollableSheet(
            initialChildSize: 0.53,
            minChildSize: 0.04,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.1, 0.53, 0.85],
            builder: (context, scrollController) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: BuildSheetContent(
                  scrollController: scrollController,
                  groupId: widget.groupId,
                  groupMembers: widget.groupMembers,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}