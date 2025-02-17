import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/floating_add_icon.dart';
import 'package:near_me_new_version/Features/group_profile/components/search_text_widget.dart';
import '../../../core/constants.dart';
import '../components/row_checkbox.dart';

class AddMembersScreen extends StatefulWidget {
  @override
  _AddMembersScreenState createState() => _AddMembersScreenState();
  static String addMembersScreenKey = '/AddMembersScreen';
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  bool isCheckboxSelected = false;

  void onCheckboxChanged(bool value) {
    setState(() {
      isCheckboxSelected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                  RowCheckbox(
                    userName: 'Hassan',
                    onChanged: onCheckboxChanged,
                  ),
                  RowCheckbox(
                    userName: 'Amira',
                    onChanged: onCheckboxChanged,
                  ),
                ],
              ),
            ),
          ),
          FloatingAddIcon(
              screenWidth: screenWidth, isCheckboxSelected: isCheckboxSelected),
        ],
      ),
    );
  }
}
