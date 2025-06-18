import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/Features/group_profile/components/search_text_widget.dart';
import 'package:near_me_new_version/Features/group_profile/components/split_between_features.dart';
import 'package:near_me_new_version/Features/share_location/components/firebase_controller.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/Features/Settings/components/confirm_message_widget.dart';
import 'package:near_me_new_version/Features/chat_group/screens/group_chat.dart';
import 'package:near_me_new_version/Features/group_profile/components/features_one.dart';
import 'package:near_me_new_version/Features/group_profile/components/leave_group.dart';
import 'package:near_me_new_version/Features/group_profile/components/members_style_widget.dart';
import 'package:near_me_new_version/Features/group_profile/components/row_add_member.dart';
import 'package:near_me_new_version/core/data/bloc/Risk/risk_bloc.dart';
import 'package:near_me_new_version/core/data/models/group.dart';
import 'package:near_me_new_version/core/services/group_services.dart';

class GroupProfileScreen extends StatefulWidget {
  static String groupProfileScreenKey = '/groupProfileScreen';

  const GroupProfileScreen({super.key});

  @override
  _GroupProfileScreenState createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  bool _isSearchExpanded = false;
  OverlayEntry? _overlayEntry;
  final GroupService _groupService = GroupService();
  Group? _group;
  bool _isDataLoaded = false;
  FirebaseController _firebaseController = FirebaseController();
  @override
  void initState() {
    super.initState();
  }

  Function(bool)? onToggle;
  late String groupId;
  bool isLiveTrackingOn = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getMapPofileArgs();
    if (!_isDataLoaded) {
      _loadGroupData();
      _isDataLoaded = true;
    }
  }

  void getMapPofileArgs() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      groupId = args['id'];
      log("id received: $groupId");
      onToggle = args['onToggle'];
      log("onToggle received: $onToggle");
      if (args.containsKey('isLiveTrackingOn')) {
        setState(() {
          isLiveTrackingOn = args['isLiveTrackingOn'];
        });
      }
    }
  }

  void _loadGroupData() async {
    log("Loading group data...");
    log("Group ID: $groupId");
    if (groupId != null) {
      Group? group = await _groupService.getGroupById(groupId);
      log("Group fetched: ${group?.name}");
      if (group != null) {
        List<Map<String, String>> membersData = [];
        for (String uid in group.members) {
          Map<String, String>? userData = await _groupService.getUserData(uid);
          if (userData != null) {
            membersData.add(userData);
          }
        }

        setState(() {
          _group = group;
          log("Group data loaded: ${_group?.name}");
        });
      } else {
        print("Group with ID $groupId not found!");
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  void _showMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
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

  void checkIfGroupHasUserLiveLocations() async {
    final hasUserLiveLocations = await _firebaseController
        .checkIfGroupHasUserLiveLocations(groupId);
    if (hasUserLiveLocations != null && hasUserLiveLocations) {
      setState(() {
        isLiveTrackingOn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                  title:
                      isCollapsed
                          ? Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(kDefaultGroupImge),
                              ),
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(top: 3, left: 5),
                                child: Text(
                                  _group?.name ?? "Loading...",
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
                            _group?.name ?? "Loading...",
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
                padding: const EdgeInsets.only(top: 15),
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
              delegate: SliverChildListDelegate([
                FeaturesOne(
                  onToggle: onToggle,
                  isLiveTrackingOn: isLiveTrackingOn,
                  id: groupId,
                ),

                SplitBetweenFeatures(),
                const SizedBox(height: 10),
                RowAddMember(
                  screenWidth: screenWidth,
                  onSearchPressed: _toggleSearch,
                  groupId: _group?.id ?? '',
                  onReturn: _loadGroupData,
                ),
                if (_isSearchExpanded) const SearchTextWidget(),
                const SizedBox(height: 30),
                if (_group == null || _group!.members.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "No members found in this group.",
                      style: TextStyle(color: kFontColor),
                    ),
                  )
                else
                  ..._group!.members.map(
                    (uid) => FutureBuilder<Map<String, String>?>(
                      future: _groupService.getUserData(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return Column(
                            children: [
                              MembersStyleWidget(
                                userName:
                                    "${snapshot.data!['fName']} ${snapshot.data!['lName']}"
                                        .trim(),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            GroupChat.groupChatKey,
            arguments: {'groupId': _group!.id, 'groupName': _group!.name},
          );
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
