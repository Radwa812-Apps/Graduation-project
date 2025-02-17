import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/members_style_widget.dart';
import '../../../core/constants.dart';
import '../../../core/constants.dart';

class SearchMember extends StatelessWidget {
  static String searchMemberKey = '/SearchMember';

  const SearchMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: const Text('Search', style: TextStyle(color: kFontColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kFontColor, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {},
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: const [
                    SizedBox(height: 30),
                    MembersStyleWidget(userName: 'Radwa'),
                    SizedBox(height: 10),
                    MembersStyleWidget(userName: 'Nada'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
