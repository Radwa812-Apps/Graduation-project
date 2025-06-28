import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/member_group_inside.dart';
import 'package:near_me_new_version/Features/share_location/components/build_search_field.dart';

import '../../Private_chat/Private_chat/screens/private_chat_screen.dart';

class BuildSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final String groupId;
  final List<Map<String, dynamic>> groupMembers;

  const BuildSheetContent({
    required this.scrollController,
    required this.groupId,
    required this.groupMembers,
    Key? key,
  }) : super(key: key);

  @override
  _BuildSheetContentState createState() => _BuildSheetContentState();
}

class _BuildSheetContentState extends State<BuildSheetContent> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      children: [
        // Search field
        BuildSearchField(),
        const SizedBox(height: 20),
        // Dynamic list of group members
        if (widget.groupMembers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "No members in this group.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...widget.groupMembers.map((member) {
            //log("Member ID: ${member['uid']}, Name: ${member['name']}, Image: ${member['encryptedUserPicture']}, Last Location: ${member['lastLocation']}, Distance: ${member['distance']}");
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PrivateChatScreen(
                              recipientId: member['uid'] ?? '',
                              recipientName: member['name'] ?? 'Unknown',
                              recipientImage: member['imageUrl'],
                            ),
                      ),
                    );
                  },
                  child: MemberGroupInside(
                    userName: member['name'] ?? 'Unknown',
                    status: member['status'] ?? 'offline',
                    distance: member['distance'] ?? 'N/A',
                    picture: member['encryptedUserPicture'] ?? '',
                    uid: member['uid'] ?? '',
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          }).toList(),
      ],
    );
  }
}
