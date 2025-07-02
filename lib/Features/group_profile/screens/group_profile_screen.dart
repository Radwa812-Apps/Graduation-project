
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:near_me_new_version/Features/Home/Home/Screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/Features/group_profile/components/search_text_widget.dart';
import 'package:near_me_new_version/Features/group_profile/components/split_between_features.dart';
import 'package:near_me_new_version/Features/share_location/components/firebase_controller.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/Features/group_profile/components/features_one.dart';
import 'package:near_me_new_version/Features/group_profile/components/leave_group.dart';
import 'package:near_me_new_version/Features/group_profile/components/members_style_widget.dart';
import 'package:near_me_new_version/Features/group_profile/components/row_add_member.dart';
import 'package:near_me_new_version/core/data/models/group.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:near_me_new_version/core/services/chat_services.dart';
import '../../chat_group/screens/group_chat.dart';
import '../../../core/services/profile_image_service.dart';

class GroupProfileScreen extends StatefulWidget {
  static String groupProfileScreenKey = '/groupProfileScreen';
  const GroupProfileScreen({super.key});

  @override
  _GroupProfileScreenState createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  bool _isSearchExpanded = false;
  bool isMenuVisible = false;
  final ProfileImageService _profileImageService = ProfileImageService();
  final GroupService _groupService = GroupService();
  Group? _group;
  bool _isDataLoaded = false;
  FirebaseController _firebaseController = FirebaseController();
  late ChatService _chatService;
  bool _isLoading = false;
  Uint8List? groupImage;
  String groupId = '';
  bool isLiveTrackingOn = false;
  Function(bool)? onToggle;
  List<Map<String, dynamic>> groupMembersList = [];

  @override
  void initState() {
    super.initState();
    _chatService = context.read<ChatService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getMapProfileArgs();

    if (!_isDataLoaded) {
      _loadGroupData();
      _isDataLoaded = true;

      _groupService.getDecryptedGroupImage(groupId).then((decrypted) {
        if (decrypted != null && mounted) {
          setState(() {
            groupImage = decrypted;
          });
        }
      });
    }
  }

  void getMapProfileArgs() {
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
    if (groupId.isNotEmpty) {
      Group? group = await _groupService.getGroupById(groupId);
      if (group != null && mounted) {
        setState(() {
          _group = group;
        });
        _loadGroupMembers(group.members);
      }
    }
  }
void _loadGroupMembers(List<String> memberIds) async {
  List<Map<String, dynamic>> membersData = [];

  for (String uid in memberIds) {
    final data = await _groupService.getUserData(uid);
    if (data != null) {
      membersData.add({
        'uid': uid,
        'name': "${data['fName']} ${data['lName']}".trim(),
        'encryptedUserPicture': data['picture'],
      });
    }
  }

  if (mounted) {
    setState(() {
      groupMembersList = membersData;
    });
  }
}

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  void _showMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: LeaveGroup(
            groupId: groupId,
            onSuccess: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.homeScreenKey,
                (route) => false,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadGroupImage() async {
    try {
      setState(() => _isLoading = true);

      final compressedBytes = await _profileImageService.pickAndCompressImage(
        context,
      );
      if (compressedBytes == null) return;

      _profileImageService.showUploadingDialog(context);

      await _groupService.uploadGroupPictureToFirestore(
        groupId: groupId,
        imageBytes: compressedBytes,
      );

      final decrypted = await _groupService.getDecryptedGroupImage(groupId);
      if (mounted && decrypted != null) {
        setState(() {
          groupImage = decrypted;
        });
      }

      _profileImageService.showSuccessMessage(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isLoading = false);
      }
    }
  }

  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    ImageProvider imageProvider = const AssetImage(kDefaultGroupImge);
    if (groupImage != null) {
      imageProvider = MemoryImage(groupImage!);
    }

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
              builder: (context, constraints) {
                bool isCollapsed =
                    constraints.biggest.height <= kToolbarHeight + 50;

                return FlexibleSpaceBar(
                  title: isCollapsed
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: imageProvider,
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
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadGroupImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: imageProvider,
                        ),
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
                  Navigator.pop(context, true);
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
                  onPressed: () => _showMenu(context),
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
                  onReturn: _loadGroupData, groupMembersList: groupMembersList,

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
                                picture: snapshot.data!['picture'],
                                uid: uid,
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
          if (_group != null) {
            Navigator.pushNamed(
              context,
              GroupChat.groupChatKey,
              arguments: {'groupId': _group!.id, 'groupName': _group!.name},
            );
          }
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

