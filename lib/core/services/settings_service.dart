import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Settings/components/group_selection_widget.dart';
import 'package:near_me_new_version/Features/Settings/components/risk_block.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:near_me_new_version/core/services/risk_services.dart';
class SettingsService extends StatefulWidget {
  const SettingsService({super.key});

  @override
  _SettingsServiceState createState() => _SettingsServiceState();
}

const _channel = MethodChannel(
  'com.example.near_me_new_version/floating_button',
);

class _SettingsServiceState extends State<SettingsService> {
  bool isAlertActive = false;
  bool isListExpanded = false;
  List<String> groupIds = [];
  List<String> selectedGroupIds = [];
  bool isRiskpressed = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RiskServices _riskServices = RiskServices();
  @override
  void initState() {
    super.initState();
    log("init........");
    _fetchGroups();
    _handleRiskSwitch();
  }

  Future<void> _fetchGroups() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      QuerySnapshot groupSnapshot =
          await _firestore
              .collection('groups')
              .where('members', arrayContains: userId)
              .get();
      if (mounted) {
        setState(() {
          groupIds = groupSnapshot.docs.map((doc) => doc.id).toList();
          print('Fetched groupIds: $groupIds');
        });
      }
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> resetUserRiskSwitches() async {
    String? userId = _auth.currentUser?.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('risk_preferences')
          .update({
            'risk_switch': false,
            'last_updated': FieldValue.serverTimestamp(),
          });
      setState(() {
        _handleRiskSwitch();
      });
      final userDoc = FirebaseFirestore.instance
          .collection('selected_alert_groups')
          .doc(userId);

      final WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.delete(userDoc);

      await batch.commit();

      print('Successfully reset ${groupIds.length} groups and removed user');
    } catch (e) {
      print('Error in resetUserRiskSwitches: $e');
    }
  }

  void _handleRiskSwitch() async {
    isAlertActive = await _riskServices.checkRiskSwitch() ?? false;
    if (mounted) {
      setState(() {});
    }
  }

  void _openGroupSelection() async {
    final userId = _auth.currentUser?.uid;
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => GroupSelectionWidget(
            groups: groupIds,
            initiallySelectedGroups: selectedGroupIds,
          ),
    );
    log("result...$result");
    if (result != null) {
      if (mounted) {
        setState(() {
          selectedGroupIds = result;
          _saveSelectedGroupsToFirebase();
        });
      }
    }
    WriteBatch batch = FirebaseFirestore.instance.batch();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('risk_preferences')
        .set({
          'risk_switch': true,
          'last_updated': FieldValue.serverTimestamp(),
        });
    log("risk activated on firebase");

    await batch.commit();
    if (mounted) {
      setState(() {
        _handleRiskSwitch();
      });
    }

    log("open group selection: isAlertactive: $isAlertActive");
  }

  Future<void> _saveSelectedGroupsToFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('selected_alert_groups').doc(userId).set({
        'groups': selectedGroupIds,
      }, SetOptions(merge: true));
      print('Saved selectedGroupIds to Firestore: $selectedGroupIds');
    } catch (e) {
      print('Error saving selected groups: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: GestureDetector(
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
                      isListExpanded
                          ? Icons.arrow_drop_down
                          : Icons.arrow_drop_up_outlined,
                      size: 30.sp,
                      color: kPrimaryColor1,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Risk Alert',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color.fromRGBO(55, 55, 55, 1),
                        fontFamily: 'Open Sans',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Switch(
              value: isAlertActive,
              activeColor: kPrimaryColor1,focusColor: kPrimaryColor1,
              onChanged: (value) async {
                if (mounted) {
                  setState(() {
                    isAlertActive = value;
                    if (isAlertActive) {
                      context.read<RiskCubit>().updateValue(true);
                      _openGroupSelection();
                    } else {
                      selectedGroupIds.clear();
                      context.read<RiskCubit>().updateValue(false);
                      resetUserRiskSwitches();
                      _riskServices.resetToggleAlert();
                    }
                  });
                }
                await _riskServices.toggleFloatingButton(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
