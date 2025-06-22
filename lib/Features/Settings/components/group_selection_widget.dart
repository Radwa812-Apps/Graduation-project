/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupSelectionWidget extends StatefulWidget {
  final List<String> groups;
  final List<String>? initiallySelectedGroups;

  const GroupSelectionWidget({
    super.key,
    required this.groups,
    this.initiallySelectedGroups,
  });

  @override
  State<GroupSelectionWidget> createState() => _GroupSelectionWidgetState();
}

class _GroupSelectionWidgetState extends State<GroupSelectionWidget> {
  late List<bool> selectedGroups;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedGroups();
  }

  Future<void> _loadSelectedGroups() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('selected_alert_groups')
                .doc(userId)
                .get();

        if (doc.exists) {
          final savedGroups = List<String>.from(doc.data()?['groups'] ?? []);
          setState(() {
            selectedGroups = List.generate(widget.groups.length, (index) {
              return savedGroups.contains(widget.groups[index]) ||
                  (widget.initiallySelectedGroups?.contains(
                        widget.groups[index],
                      ) ??
                      false);
            });
            _isLoading = false;
          });
        } else {
          _initializeSelectedGroups();
        }
      } else {
        _initializeSelectedGroups();
      }
    } catch (e) {
      _initializeSelectedGroups();
    }
  }

  void _initializeSelectedGroups() {
    setState(() {
      selectedGroups = List.generate(widget.groups.length, (index) {
        return widget.initiallySelectedGroups?.contains(widget.groups[index]) ??
            false;
      });
      _isLoading = false;
    });
  }

  void toggleSelection(int index) {
    setState(() {
      selectedGroups[index] = !selectedGroups[index];
    });
  }

  Future<void> saveSelectedGroupsToFirebase(List<String> selectedGroups) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('selected_alert_groups')
          .doc(userId)
          .set({'groups': selectedGroups}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving groups: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 347.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'Select the groups you want to send to',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.normal,
                    color: kFontColor,
                  ),
                ),
              ),
              Divider(height: 24.h, color: Colors.grey[200]),

              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (widget.groups.isEmpty)
                const Expanded(
                  child: Center(child: Text('No groups available.')),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.groups.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      // Fetch group name from Firestore to display
                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('groups')
                                .doc(widget.groups[index])
                                .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return ListTile(title: Text(widget.groups[index]));
                          }
                          final groupName =
                              snapshot.data?.get('name') as String? ??
                              widget.groups[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color:
                                  selectedGroups[index]
                                      ? const Color(
                                        0xFF3D5300,
                                      ).withOpacity(0.05)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    selectedGroups[index]
                                        ? kPrimaryColor1
                                        : Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                if (selectedGroups[index])
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3D5300,
                                    ).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => toggleSelection(index),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48.w,
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/group.jpg',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color:
                                              selectedGroups[index]
                                                  ? kPrimaryColor1
                                                  : Colors.grey[300]!,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Text(
                                        groupName,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF333333),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => toggleSelection(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: 24.w,
                                        height: 24.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              selectedGroups[index]
                                                  ? kPrimaryColor1
                                                  : Colors.transparent,
                                          border: Border.all(
                                            color:
                                                selectedGroups[index]
                                                    ? kPrimaryColor1
                                                    : Colors.grey[400]!,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child:
                                                selectedGroups[index]
                                                    ? Icon(
                                                      Icons.check,
                                                      size: 16.w,
                                                      color: Colors.white,
                                                    )
                                                    : const SizedBox(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor1,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final selectedGroupIds = <String>[];
                    for (int i = 0; i < selectedGroups.length; i++) {
                      if (selectedGroups[i]) {
                        selectedGroupIds.add(widget.groups[i]);
                      }
                    }
                    await saveSelectedGroupsToFirebase(selectedGroupIds);
                    if (mounted) {
                      Navigator.pop(context, selectedGroupIds);
                    }
                  },
                  child: Text(
                    'Confirm Selection',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/


import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/core/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:near_me_new_version/core/services/group_services.dart';

class GroupSelectionWidget extends StatefulWidget {
  final List<String> groups;
  final List<String>? initiallySelectedGroups;

  const GroupSelectionWidget({
    super.key,
    required this.groups,
    this.initiallySelectedGroups,
  });

  @override
  State<GroupSelectionWidget> createState() => _GroupSelectionWidgetState();
}

class _GroupSelectionWidgetState extends State<GroupSelectionWidget> {
  late List<bool> selectedGroups;
  bool _isLoading = true;
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadSelectedGroups();
  }

  Future<void> _loadSelectedGroups() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('selected_alert_groups')
            .doc(userId)
            .get();

        if (doc.exists) {
          final savedGroups = List<String>.from(doc.data()?['groups'] ?? []);
          setState(() {
            selectedGroups = List.generate(widget.groups.length, (index) {
              return savedGroups.contains(widget.groups[index]) ||
                  (widget.initiallySelectedGroups?.contains(
                            widget.groups[index],
                          ) ??
                      false);
            });
            _isLoading = false;
          });
        } else {
          _initializeSelectedGroups();
        }
      } else {
        _initializeSelectedGroups();
      }
    } catch (e) {
      _initializeSelectedGroups();
    }
  }

  void _initializeSelectedGroups() {
    setState(() {
      selectedGroups = List.generate(widget.groups.length, (index) {
        return widget.initiallySelectedGroups?.contains(widget.groups[index]) ??
            false;
      });
      _isLoading = false;
    });
  }

  void toggleSelection(int index) {
    setState(() {
      selectedGroups[index] = !selectedGroups[index];
    });
  }

  Future<void> saveSelectedGroupsToFirebase(List<String> selectedGroups) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('selected_alert_groups')
          .doc(userId)
          .set({'groups': selectedGroups}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving groups: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'Select the groups you want to send to',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.normal,
                  color: kFontColor,
                ),
              ),
            ),
            Divider(height: 24.h, color: Colors.grey[200]),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.groups.isEmpty)
              const Center(child: Text('No groups available.'))
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: widget.groups.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final groupId = widget.groups[index];
                    return FutureBuilder<Uint8List?>(
                      future: _groupService.getDecryptedGroupImage(groupId),
                      builder: (context, snapshot) {
                        final image = snapshot.data;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: selectedGroups[index]
                                ? const Color(0xFF3D5300).withOpacity(0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedGroups[index]
                                  ? kPrimaryColor1
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => toggleSelection(index),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48.w,
                                    height: 48.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: image != null
                                            ? MemoryImage(image)
                                            : const AssetImage(
                                                    'assets/images/group.jpg')
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        color: selectedGroups[index]
                                            ? kPrimaryColor1
                                            : Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('groups')
                                          .doc(groupId)
                                          .get(),
                                      builder: (context, snapshot) {
                                        final groupName = snapshot.data?.get('name') ?? groupId;
                                        return Text(
                                          groupName,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF333333),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => toggleSelection(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 24.w,
                                      height: 24.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selectedGroups[index]
                                            ? kPrimaryColor1
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: selectedGroups[index]
                                              ? kPrimaryColor1
                                              : Colors.grey[400]!,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: selectedGroups[index]
                                            ? Icon(Icons.check,
                                                size: 16.w,
                                                color: Colors.white)
                                            : const SizedBox(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor1,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final selectedGroupIds = <String>[];
                  for (int i = 0; i < selectedGroups.length; i++) {
                    if (selectedGroups[i]) {
                      selectedGroupIds.add(widget.groups[i]);
                    }
                  }
                  await saveSelectedGroupsToFirebase(selectedGroupIds);
                  if (mounted) {
                    Navigator.pop(context, selectedGroupIds);
                  }
                },
                child: Text(
                  'Confirm Selection',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
