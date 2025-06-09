import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/Features/share_location/components/is_tracking_on_block.dart';
import '../../../core/constants.dart';

bool sharingLocation = false; // Default value for sharing location

class SwitchWidget extends StatefulWidget {
  final bool initialFeatureStatus;
  final bool isSharingLocationPressed;
  final Function(bool)? onToggle; // ← New callback
  final bool isLiveTrackingOn; // ← New parameter
  SwitchWidget({
    super.key,
    this.initialFeatureStatus = false,
    this.isSharingLocationPressed = false,
    this.onToggle,
    this.isLiveTrackingOn = false, // ← New param
  });

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  late bool _featureEnabled;

  @override
  void initState() {
    super.initState();
    if (widget.isLiveTrackingOn) {
      log("Live tracking is enabled");
      _featureEnabled = true;
    } else {
      log("Live tracking is disabled");
      _featureEnabled = widget.initialFeatureStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _featureEnabled,

      onChanged: (bool value) {
        setState(() {
          _featureEnabled = value;
          context.read<TrackingOnCubit>().updateValue(value);
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
