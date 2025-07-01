import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/screens/add_members_screen.dart';
import '../../../core/constants.dart';
import '../screens/search_member.dart';

class RowAddMember extends StatelessWidget {
  const RowAddMember({
    super.key,
    required this.screenWidth,
    required this.onSearchPressed,
    required this.groupId,
    required this.onReturn,
    required this.groupMembersList,
  });

  final double screenWidth;
  final VoidCallback onSearchPressed;
  final String groupId;
  final VoidCallback onReturn;
  final List<Map<String, dynamic>> groupMembersList;
  @override
  Widget build(BuildContext context) {
    log("RowAddMember: Building RowAddMember with groupId: $groupId");
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AddMembersScreen.addMembersScreenKey,
                arguments: groupId,
              ).then((_) {
                onReturn();
              });
            },
            child: Row(
              children: const [
                Icon(
                  Icons.person_add_alt_1_outlined,
                  size: 28,
                  color: kPrimaryColor1,
                ),
                SizedBox(width: 10),
                Text(
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
          const Spacer(flex: 1),
          IconButton(
            icon: const Icon(Icons.search, size: 28, color: kPrimaryColor1),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SearchMember(
                          groupMembers:
                              groupMembersList, // هات الداتا هنا من الفايربيز أو السيرفيس بتاعك
                        ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
