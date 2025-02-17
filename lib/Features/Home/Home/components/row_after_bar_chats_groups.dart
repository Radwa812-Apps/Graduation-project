import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants.dart';

class RowAfterBarChatsGroups extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabSelected;
  const RowAfterBarChatsGroups({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
   return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onTabSelected('Chats'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: selectedTab == 'Chats'
                    ? kPrimaryColor1.withOpacity(0.2) 
                    : Colors.transparent, 
                borderRadius: BorderRadius.circular(10.r), 
              ),
              child: Text(
                'Chats',
                style: TextStyle(
                  color: selectedTab == 'Chats' ? kPrimaryColor1 : kFontColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w), 
          GestureDetector(
            onTap: () => onTabSelected('Groups'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: selectedTab == 'Groups'
                    ? kPrimaryColor1.withOpacity(0.2) 
                    : Colors.transparent, 
                borderRadius: BorderRadius.circular(10.r), 
              ),
              child: Text(
                'Groups',
                style: TextStyle(
                  color: selectedTab == 'Groups' ? kPrimaryColor1 : kFontColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
