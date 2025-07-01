import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/members_style_widget.dart';
import 'package:near_me_new_version/Features/share_location/components/build_search_field.dart';
import '../../../core/constants.dart';

class SearchMember extends StatefulWidget {
  static String searchMemberKey = '/SearchMember';

  final List<Map<String, dynamic>> groupMembers;

  const SearchMember({super.key, required this.groupMembers});

  @override
  State<SearchMember> createState() => _SearchMemberState();
}

class _SearchMemberState extends State<SearchMember> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> filteredMembers;

  @override
  void initState() {
    super.initState();

    // نسخة منفصلة من groupMembers علشان نفلتر عليها بدون التعديل على widget.groupMembers
    filteredMembers = List<Map<String, dynamic>>.from(widget.groupMembers);

    // ديباج للتأكيد
    print("🔍 Members received (${filteredMembers.length}):");
    for (var member in filteredMembers) {
      print(" - ${member['name']}");
    }

    _searchController.addListener(_filterMembers);
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      filteredMembers = widget.groupMembers.where((member) {
        final name = (member['name'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMembers);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: const Text('Search', style: TextStyle(color: kFontColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor1, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BuildSearchField(controller: _searchController),
            ),
            Expanded(
              child: filteredMembers.isEmpty
                  ? const Center(child: Text("No members found."))
                  : ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        final name = member['name'] ?? '';
                        final uid = member['uid'] ?? '';
                        final picture = member['encryptedUserPicture'];

                        if (name.trim().isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 10,
                          ),
                          child: MembersStyleWidget(
                            userName: name,
                            picture: picture,
                            uid: uid,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
