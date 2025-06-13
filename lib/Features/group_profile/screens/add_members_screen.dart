import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/floating_add_icon.dart';
import 'package:near_me_new_version/Features/group_profile/components/search_text_widget.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import 'package:near_me_new_version/Features/group_profile/components/row_checkbox.dart';

class AddMembersScreen extends StatefulWidget {
  static String addMembersScreenKey = '/AddMembersScreen';

  const AddMembersScreen({super.key});

  @override
  _AddMembersScreenState createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final GroupService _groupService = GroupService();
  List<Map<String, dynamic>> _allUsers = [];
  List<String> _selectedUids = [];
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadUsers();
      _isDataLoaded = true;
    }
  }

  void _loadUsers() async {
    final String? groupId =
        ModalRoute.of(context)?.settings.arguments as String?;
    log("AddMembersScreen: Loading users for groupId: $groupId");
    if (groupId == null) {
      setState(() {
        _isDataLoaded = true;
      });
      return;
    }

    List<Map<String, dynamic>> users =
        await _groupService.getUsersFromContacts();
    final group = await _groupService.getGroupById(groupId);
    if (group != null) {
      List<Map<String, dynamic>> filteredUsers =
          users.where((user) {
            return !group.members.contains(user['uid']);
          }).toList();
      log("Filtered users: ${filteredUsers.length} out of ${users.length}");
      setState(() {
        _allUsers = filteredUsers;
        _isDataLoaded = true;
      });
    } else {
      setState(() {
        _allUsers = users;
        _isDataLoaded = true;
      });
    }
  }

  void _onCheckboxChanged(String uid, bool value) {
    setState(() {
      if (value) {
        _selectedUids.add(uid);
      } else {
        _selectedUids.remove(uid);
      }
    });
  }

  void _addMembers() async {
    final String? groupId =
        ModalRoute.of(context)?.settings.arguments as String?;
    if (groupId != null && _selectedUids.isNotEmpty) {
      await _groupService.addMembersToGroup(groupId, _selectedUids);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Members added successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      String errorMessage = "Please select at least one member!";
      if (groupId == null) {
        errorMessage = "Error: Group ID is missing!";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
log("AddMembersScreen: Building with screenWidth: $_allUsers");
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: kBackgroundColor,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: kFontColor,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Add Members',
              style: TextStyle(
                color: kFontColor,
                fontSize: 20,
                fontFamily: kFontRegular,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SearchTextWidget(),
                  const SizedBox(height: 10),
                  if (!_isDataLoaded)
                    const Center(child: CircularProgressIndicator())
                  else if (_allUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No available contacts to add.",
                        style: TextStyle(color: kFontColor),
                      ),
                    )
                  else
                    ..._allUsers.map(
                      (user) => RowCheckbox(
                        userName: "${user['fName']} ${user['lName']}".trim(),
                        initialValue: _selectedUids.contains(user['uid']),
                        onChanged:
                            (value) => _onCheckboxChanged(user['uid'], value),
                      ),
                    ),
                ],
              ),
            ),
          ),
          FloatingAddIcon(
            screenWidth: screenWidth,
            isCheckboxSelected: _selectedUids.isNotEmpty,
            onPressed: _addMembers,
          ),
        ],
      ),
    );
  }
}
