
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Settings/components/group_selection_widget.dart';
import 'package:near_me_new_version/Features/group_profile/components/switch_widget.dart';
import 'package:near_me_new_version/core/constants.dart';

class SettingsService extends StatefulWidget {
  const SettingsService({super.key});

  @override
  _SettingsServiceState createState() => _SettingsServiceState();
}

class _SettingsServiceState extends State<SettingsService> {
  bool isAlertActive = false;
  bool isListExpanded = false;
  List<String> groupIds = []; 
  List<String> selectedGroupIds = []; 

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      QuerySnapshot groupSnapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();

      setState(() {
        groupIds = groupSnapshot.docs.map((doc) => doc.id).toList(); 
        print('Fetched groupIds: $groupIds');
      });
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  void _openGroupSelection() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => GroupSelectionWidget(
        groups: groupIds, 
        initiallySelectedGroups: selectedGroupIds,
      ),
    );

    if (result != null) {
      setState(() {
        selectedGroupIds = result;
        _saveSelectedGroupsToFirebase(); 
      });
    }
  }

  Future<void> _saveSelectedGroupsToFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('selected_alert_groups')
          .doc(userId)
          .set({'groups': selectedGroupIds}, SetOptions(merge: true));
      print('Saved selectedGroupIds to Firestore: $selectedGroupIds');
    } catch (e) {
      print('Error saving selected groups: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isListExpanded = !isListExpanded;
                  });
                  if (isListExpanded) {
                    _openGroupSelection();
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      isListExpanded ? Icons.arrow_drop_down : Icons.arrow_drop_up_outlined,
                      size: 30.sp,
                      color: kPrimaryColor1,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Quick Risk Alert',
                      style: TextStyle(
                        color: const Color.fromRGBO(55, 55, 55, 1),
                        fontFamily: 'Open Sans',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.normal,
                        height: 0.9166,
                      ),
                    ),
                  ],
                ),
              ),
              SwitchWidget(
                initialFeatureStatus: isAlertActive,
                onChanged: (value) {
                  setState(() {
                    isAlertActive = value;
                    if (!isAlertActive) isListExpanded = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
