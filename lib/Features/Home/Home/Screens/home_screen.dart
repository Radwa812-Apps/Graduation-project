import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Home/Home/components/chat_list.dart';
import 'package:near_me_new_version/Features/share_location/screens/live_location_map.dart';
import 'package:near_me_new_version/core/data/models/group.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:provider/provider.dart';
import 'package:near_me_new_version/core/services/chat_services.dart';
import '../../../../core/constants.dart';
import '../components/container_text_field_widget.dart';
import '../components/floating_yellow_icon.dart';
import '../components/group_style.dart';
import '../components/home_bar_widget.dart';
import '../components/row_after_bar_chats_groups.dart';

class HomeScreen extends StatefulWidget {
  static const String homeScreenKey = '/HomeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  bool _isDraggableSheetVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();
  String _selectedTab = 'Groups';
  final GroupService _groupService = GroupService();
  late ChatService _chatService;
  List<Group> _groups = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    _loadGroups();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  bool _hasSubscribedToStream = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasSubscribedToStream) {
      _hasSubscribedToStream = true;
      _groupService.streamMyGroups().listen((fetchedGroups) {
        if (mounted) {
          setState(() {
            _groups = fetchedGroups;
          });
        }
      });
    }
  }

  void _loadGroups() async {
    List<Group> fetchedGroups = await _groupService.getMyGroups();
    setState(() {
      _groups = fetchedGroups;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _toggleDraggableSheet() {
    setState(() {
      _isDraggableSheetVisible = !_isDraggableSheetVisible;
    });
  }

  void _expandDraggableSheet() {
    _draggableScrollableController.animateTo(
      0.6,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectTab(String tabName) {
    setState(() {
      _selectedTab = tabName;
      _isDraggableSheetVisible = false;
    });
  }

  void _addGroup(String groupName) async {
    if (groupName.isNotEmpty) {
      String? groupId = await _groupService.makeNewGroup(
        groupName,
        "No description yet",
      );
      if (groupId != null) {
        await _groupService.addGroupToUser(groupId);
        setState(() {
          _isDraggableSheetVisible = false;
        });
      }
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    int millisecondsSinceEpoch;

    if (timestamp is Timestamp) {
      millisecondsSinceEpoch = timestamp.millisecondsSinceEpoch;
    } else if (timestamp is int) {
      millisecondsSinceEpoch = timestamp;
    } else {
      return '';
    }

    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  List<Group> _filterGroups(List<Group> groups) {
    if (_searchQuery.isEmpty) return groups;
    return groups
        .where((group) => group.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    log(
      "Building HomeScreen with selected tab: $_selectedTab, search query: $_searchQuery",
    );
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kBackgroundColor,
      appBar: HomeAppBar(
        isSearching: _isSearching,
        onSearchPressed: _toggleSearch,
        onClosePressed: _toggleSearch,
        searchController: _searchController,
        onSearch: _performSearch,
        onSearchChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                RowAfterBarChatsGroups(
                  selectedTab: _selectedTab,
                  onTabSelected: _selectTab,
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child:
                      _selectedTab == 'Groups'
                          ? StreamBuilder<List<Group>>(
                            stream: _groupService.getMyGroupsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final groups = _filterGroups(snapshot.data ?? []);

                              if (groups.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 100),
                                  child: Image.asset(
                                    'assets/images/noGroups.png',
                                    width: screenWidth * .8.w,
                                    height: screenHeight * .8.h,
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.only(bottom: 20.h),
                                itemCount: groups.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => OrderTrackingPage(
                                                  groupId: groups[index].id,
                                                  groupName: groups[index].name,
                                                ),
                                          ),
                                        );
                                        if (mounted) setState(() {});
                                      },
                                      child: GroupStyle(
                                        groupName: groups[index].name,
                                        groupId: groups[index].id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                          : ChatsList(
                            formatTime: _formatTime,
                            searchQuery: _searchQuery,
                          ),
                ),
              ],
            ),
          ),
          if (_selectedTab == 'Groups') ...[
            if (_isDraggableSheetVisible)
              GestureDetector(
                onTap: _toggleDraggableSheet,
                child: ContainerTextFieldWidget(
                  onTextFieldFocus: _expandDraggableSheet,
                  draggableScrollableController: _draggableScrollableController,
                  onSubmitted: (groupName) {
                    _addGroup(groupName);
                  },
                ),
              ),
            if (!_isDraggableSheetVisible)
              FloatingYellowIcon(toggleDraggableSheet: _toggleDraggableSheet),
          ],
        ],
      ),
    );
  }
}
