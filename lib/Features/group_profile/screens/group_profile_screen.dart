import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/search_text_widget.dart';
import 'package:near_me_new_version/Features/group_profile/components/split_between_features.dart';
import '../../../core/constants.dart';
import '../../Settings/components/confirm_message_widget.dart';
import '../../chat_group/screens/group_chat.dart';
import '../components/features_one.dart';
import '../components/leave_group.dart';
import '../components/members_style_widget.dart';
import '../components/row_add_member.dart';

class GroupProfileScreen extends StatefulWidget {
  static String groupProfileScreenKey = '/groupProfileScreen';

  const GroupProfileScreen({super.key});

  @override
  _GroupProfileScreenState createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  bool _isSearchExpanded = false;
  OverlayEntry? _overlayEntry;

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  void _showMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: 100,
                left: 200,
                child: Material(
                  color: Colors.transparent,
                  child: LeaveGroup(
                    onLeaveGroupPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmMessageWidget(
                            message:
                                'Are you sure you want to leave the group?',
                            onCancel: () {
                              Navigator.of(context).pop();
                            },
                            onConfirm: () {
                              Navigator.of(context).pop();
                              print('User confirmed leaving the group');
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final String? groupNameR =
        ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: kBackgroundColor,
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double appBarHeight = constraints.biggest.height;
                bool isCollapsed = appBarHeight <= kToolbarHeight + 50;

                return FlexibleSpaceBar(
                  title: isCollapsed
                      ? Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(kDefaultGroupImge),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 3, left: 5),
                              child: Text(
                                groupNameR!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: kFontBold,
                                  fontWeight: FontWeight.bold,
                                  color: kFontColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                  background: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage(kDefaultGroupImge),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            groupNameR!,
                            style: const TextStyle(
                              fontSize: 30,
                              fontFamily: kFontBold,
                              fontWeight: FontWeight.bold,
                              color: kFontColor,
                            ),
                          ),
                        ],
                      ),
                      if (isCollapsed)
                        const Positioned(
                          left: 10,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(kDefaultGroupImge),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 15),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: kPrimaryColor1,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: kPrimaryColor1,
                    size: 28,
                  ),
                  onPressed: () {
                    _showMenu(context);
                  },
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const FeaturesOne(),
                  SplitBetweenFeatures(),
                  const SizedBox(height: 10),
                  RowAddMember(
                    screenWidth: screenWidth,
                    onSearchPressed: _toggleSearch,
                  ),
                  if (_isSearchExpanded) const SearchTextWidget(),
                  const SizedBox(height: 30),
                  const MembersStyleWidget(userName: 'Radwa'),
                  const SizedBox(height: 10),
                  const MembersStyleWidget(userName: 'Nada'),
                  const SizedBox(height: 10),
                  const MembersStyleWidget(userName: 'Radwa'),
                  const SizedBox(height: 10),
                  const MembersStyleWidget(userName: 'Nada'),
                  const SizedBox(height: 10),
                  const MembersStyleWidget(userName: 'Radwa'),
                  const SizedBox(height: 10),
                  const MembersStyleWidget(userName: 'Nada'),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, GroupChat.groupChatKey,
              arguments: groupNameR);
        },
        backgroundColor: kPrimaryColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}
