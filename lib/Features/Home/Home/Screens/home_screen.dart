import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_inside.dart';
import 'package:near_me_new_version/Features/group_profile/screens/group_profile_screen.dart';
import 'package:near_me_new_version/Features/share_location/screens/live_location_map.dart';
import 'package:near_me_new_version/core/data/models/group.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants.dart';
import '../components/container_text_field_widget.dart';
import '../components/floating_yellow_icon.dart';
import '../components/group_style.dart';
import '../components/home_bar_widget.dart';
import '../components/row_after_bar_chats_groups.dart';

class HomeScreen extends StatefulWidget {
  static String homeScreenKey = '/HomeScreen';

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
  List<Group> _groups = [];
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadGroups();
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
      }
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      print('Performing search for: $query');
    } else {
      print('Search query is empty');
    }
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
        _loadGroups();
        setState(() {
          _isDraggableSheetVisible = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          print('Search query: $value');
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
                  child: _selectedTab == 'Groups'
                      ? (_groups.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Image.asset(
                                'assets/images/noGroups.png',
                                width: screenWidth * .8.w,
                                height: screenHeight * .8.h,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _groups.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        OrderTrackingPage.OrderTrackingScreenKey,
                                        arguments: _groups[index].id,
                                      );
                                    },
                                    child: GroupStyle(
                                      groupName: _groups[index].name,
                                      groupId: _groups[index].id, 
                                    ),
                                  ),
                                );
                              },
                            ))
                      : Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Image.asset(
                            'assets/images/noChats.png',
                            width: screenWidth * .8.w,
                            height: screenHeight * .8.h,
                          ),
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