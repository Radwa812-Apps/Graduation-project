// import 'package:flutter/material.dart';
// import 'package:nearme_app/Features/Home/Home/components/home_bar_widget.dart';
// import 'package:nearme_app/core/constants.dart';
// import '../components/container_text_field_widget.dart';
// import '../components/floating_yellow_icon.dart';
// import '../components/group_style.dart';
// import '../components/row_after_bar_chats_groups.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
//   static String homeScreenKey = '/HomeScreen';
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isSearching = false;
//   bool _isDraggableSheetVisible = false;
//   final TextEditingController _searchController = TextEditingController();
//   final DraggableScrollableController _draggableScrollableController =
//       DraggableScrollableController();
//   String _selectedTab =
//       'Groups';
//   List<String> _groups = [];
//   // Toggle search bar visibility
//   void _toggleSearch() {
//     setState(() {
//       _isSearching = !_isSearching;
//       if (!_isSearching) {
//         _searchController.clear();
//       }
//     });
//   }

//   // Perform search operation
//   void _performSearch() {
//     final query = _searchController.text.trim();
//     if (query.isNotEmpty) {
//       print('Performing search for: $query');
//     } else {
//       print('Search query is empty');
//     }
//   }

//   // Toggle visibility of draggable sheet
//   void _toggleDraggableSheet() {
//     setState(() {
//       _isDraggableSheetVisible = !_isDraggableSheetVisible;
//     });
//   }

//   // Expand the draggable sheet when the text field is focused
//   void _expandDraggableSheet() {
//     _draggableScrollableController.animateTo(0.6,
//         duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//   }

//   // Switch between "Chats" and "Groups" tabs
//   void _selectTab(String tabName) {
//     setState(() {
//       _selectedTab = tabName;
//       _isDraggableSheetVisible = false; // Hide the sheet when switching tabs
//     });
//   }

//   // Add a new group to the list
//   void _addGroup(String groupName) {
//     if (groupName.isNotEmpty) {
//       setState(() {
//         _groups.add(groupName);
//         _isDraggableSheetVisible = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: kBackgroundColor,
//       appBar: HomeAppBar(
//         isSearching: _isSearching,
//         onSearchPressed: _toggleSearch,
//         onClosePressed: _toggleSearch,
//         searchController: _searchController,
//         onSearch: _performSearch,
//         onSearchChanged: (value) {
//           print('Search query: $value');
//         },
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               // Row below the app bar for "Chats" or "Groups"
//               RowAfterBarChatsGroups(
//                 selectedTab: _selectedTab,
//                 onTabSelected: _selectTab,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),

//               // Main content: Show groups or chats
//               Expanded(
//                   child: _selectedTab == 'Groups'
//                       ? (_groups.isEmpty
//                           ? Padding(
//                               padding: const EdgeInsets.only(bottom: 100),
//                               child: Image.asset('assets/images/noGroups.png',
//                                   width: screenWidth * .8,
//                                   height: screenHeight * .8),
//                             )
//                           : ListView.builder(
//                               itemCount: _groups.length,
//                               itemBuilder: (context, index) {
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10.0, vertical: 4.0),
//                                   child: GroupStyle(
//                                     groupName: _groups[index],
//                                   ),
//                                 );
//                               },
//                             ))
//                       : Padding(
//                           padding: const EdgeInsets.only(bottom: 100),
//                           child: Image.asset('assets/images/noChats.png',
//                               width: screenWidth * .8,
//                               height: screenHeight * .8),
//                         )),

//               // Bottom container with icons
//             ],
//           ),

//           // Show draggable sheet and floating icon only for "Groups" tab
//           if (_selectedTab == 'Groups') ...[
//             // Draggable sheet for adding a group
//             if (_isDraggableSheetVisible)
//               GestureDetector(
//                 onTap: _toggleDraggableSheet,
//                 child: ContainerTextFieldWidget(
//                   onTextFieldFocus: _expandDraggableSheet,
//                   draggableScrollableController: _draggableScrollableController,
//                   onSubmitted: (groupName) {
//                     _addGroup(groupName); // Add the group when submitted
//                   },
//                 ),
//               ),

//             // Floating yellow icon for opening the draggable sheet
//             if (!_isDraggableSheetVisible)
//               FloatingYellowIcon(toggleDraggableSheet: _toggleDraggableSheet),
//           ],
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants.dart';
import '../components/container_text_field_widget.dart';
import '../components/floating_yellow_icon.dart';
import '../components/group_style.dart';
import '../components/home_bar_widget.dart';
import '../components/row_after_bar_chats_groups.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  static String homeScreenKey = '/HomeScreen';
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  bool _isDraggableSheetVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();
  String _selectedTab = 'Groups';
  List<String> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  // Load groups from SharedPreferences
  void _loadGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _groups = prefs.getStringList('groups') ?? [];
    });
  }

  // Save groups to SharedPreferences
  void _saveGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('groups', _groups);
  }

  // Toggle search bar visibility
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  // Perform search operation
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      print('Performing search for: $query');
    } else {
      print('Search query is empty');
    }
  }

  // Toggle visibility of draggable sheet
  void _toggleDraggableSheet() {
    setState(() {
      _isDraggableSheetVisible = !_isDraggableSheetVisible;
    });
  }

  // Expand the draggable sheet when the text field is focused
  void _expandDraggableSheet() {
    _draggableScrollableController.animateTo(
      0.6,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Switch between "Chats" and "Groups" tabs
  void _selectTab(String tabName) {
    setState(() {
      _selectedTab = tabName;
      _isDraggableSheetVisible = false; // Hide the sheet when switching tabs
    });
  }

  // Add a new group to the list
  void _addGroup(String groupName) {
    if (groupName.isNotEmpty) {
      setState(() {
        _groups.add(groupName);
        _isDraggableSheetVisible = false;
        _saveGroups(); // Save groups after adding
      });
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
                  child:
                      _selectedTab == 'Groups'
                          ? (_groups.isEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(bottom: 100),
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
                                    child: GroupStyle(
                                      groupName: _groups[index],
                                    ),
                                  );
                                },
                              ))
                          : Padding(
                            padding: const EdgeInsets.only(bottom: 100),
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
