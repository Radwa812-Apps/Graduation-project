
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filteredMembers = widget.groupMembers.where((member) {
      final name = member['name']?.toLowerCase() ?? '';
      return name.contains(query);
    }).toList();

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      children: [
        BuildSearchField(controller: _searchController),
        const SizedBox(height: 20),
        if (filteredMembers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "No members found.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...filteredMembers.map((member) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivateChatScreen(
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
