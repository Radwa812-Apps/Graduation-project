import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/Features/share_location/components/firebase_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/is_tracking_on_block.dart';
import '../../../core/constants.dart';

bool sharingLocation = false; // Default value for sharing location

class SwitchWidget extends StatefulWidget {
  final bool initialFeatureStatus;
  final bool isSharingLocationPressed;
  final Function(bool)? onToggle; // ← New callback
  final String id; // ← New parameter
  final bool isLiveTrackingOn; // ← New parameter
  final bool isRiskPresserd;
  SwitchWidget({
    super.key,
    this.initialFeatureStatus = false,
    this.isSharingLocationPressed = false,
    this.onToggle,
    this.isLiveTrackingOn = false, // ← New param
    this.id = '', // ← New parameter
    this.isRiskPresserd = false,
  });

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  bool _featureEnabled = false;

  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
  LocationData? currentLocation;
  late Location location;
  FirebaseController _firebaseController = FirebaseController();
  @override
  void initState() {
    super.initState();
    // if (widget.isLiveTrackingOn) {
    //   log("Live tracking is enabled");
    //   _featureEnabled = true;
    // } else {
    //   log("Live tracking is disabled");
    //   _featureEnabled = widget.initialFeatureStatus;
    // }
    isUserLiveLocationOn();
  }

  void isUserLiveLocationOn() async {
    final hasUserLiveLocations = await _firebaseController
        .checkIfGroupHasUserLiveLocations(widget.id);
    if (hasUserLiveLocations != null && hasUserLiveLocations) {
      _featureEnabled = true;
    } else if (widget.isLiveTrackingOn) {
      log("Live tracking is enabled");
      _featureEnabled = true;
    } else {
      log("Live tracking is disabled");
      _featureEnabled = widget.initialFeatureStatus;
    }
    log("??????????????????????? $_featureEnabled");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _featureEnabled,
      onChanged: (bool value) async {
        setState(() {
          _featureEnabled = value;
          context.read<TrackingUserOnCubit>().updateValue(value);
        });

        if (widget.isSharingLocationPressed) {
          sharingLocation = value;
        }
        log("value: $value");
        log("featureEnabled: $_featureEnabled");
        //Invoke the callback from parent
        if (widget.onToggle != null) {
          log("Calling parent's toggleLiveTracking with value: $value");
          widget.onToggle!(
            value,
          ); // ← Call parent's _hanldeLiveLocationInstance
        }
      },
      activeColor: kPrimaryColor1,
    );
  }
}
