import 'dart:developer';
import 'package:location/location.dart';
import 'package:near_me_new_version/core/data/models/userRadwa.dart'
    as user_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/Features/share_location/components/is_tracking_on_block.dart';
import 'package:near_me_new_version/core/data/models/group.dart' as group_model;
import 'package:near_me_new_version/core/data/models/userRadwa.dart';
import 'package:near_me_new_version/core/services/group_services.dart';
import '../../../core/constants.dart';

bool sharingLocation = false; // Default value for sharing location

class SwitchWidget extends StatefulWidget {
  final bool initialFeatureStatus;
  final bool isSharingLocationPressed;
  final Function(bool)? onToggle; // ← New callback
  final String id; // ← New parameter
  final bool isLiveTrackingOn; // ← New parameter
  SwitchWidget({
    super.key,
    this.initialFeatureStatus = false,
    this.isSharingLocationPressed = false,
    this.onToggle,
    this.isLiveTrackingOn = false, // ← New param
    this.id = '', // ← New parameter
  });

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  late bool _featureEnabled;
  // final GroupService _groupService = GroupService();
  // group_model.Group? group = null;
  // void getGroupById(String groupId) async {
  //   group_model.Group? _group = await _groupService.getGroupById(groupId);
  //   if (_group != null) {
  //     log("Group found: ${_group.name}");
  //     group = _group;
  //   } else {
  //     log("Group not found with ID: $groupId");
  //     group = null;
  //   }
  // }
  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
  LocationData? currentLocation;
  late Location location;

  @override
  void initState() {
    super.initState();
    //location = Location();
    //_initLocation();
    if (widget.isLiveTrackingOn) {
      log("Live tracking is enabled");
      _featureEnabled = true;
    } else {
      log("Live tracking is disabled");
      _featureEnabled = widget.initialFeatureStatus;
    }
  }

  Future<void> _initLocation() async {
    currentLocation = await location.getLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _featureEnabled,

      onChanged: (bool value) {
        setState(() {
          _featureEnabled = value;
          context.read<TrackingOnCubit>().updateValue(value);
          //   if (value) {
          //     log("Live tracking is now enabled");
          //     FirebaseFirestore.instance
          //         .collection('groups')
          //         .doc(widget.id)
          //         .collection('live_locations')
          //         .doc(user!.uid)
          //         .set({
          //           'latitude': currentLocation!.latitude,
          //           'longitude': currentLocation!.longitude,
          //           'timestamp': FieldValue.serverTimestamp(),
          //         });
          //   } else {
          //     log("Live tracking is now disabled");
          //     FirebaseFirestore.instance
          //         .collection('groups')
          //         .doc(widget.id)
          //         .collection('live_locations')
          //         .doc(user!.uid)
          //         .delete();
          //   }
        });

        if (widget.isSharingLocationPressed) {
          sharingLocation = value;
        }
        log("value: $value");
        log("featureEnabled: $_featureEnabled");
        // Invoke the callback from parent
        if (widget.onToggle != null) {
          log("Calling parent's toggleLiveTracking with value: $value");
          widget.onToggle!(value); // ← Call parent's toggleLiveTracking
        }
      },
      activeColor: kPrimaryColor1,
    );
  }
}
