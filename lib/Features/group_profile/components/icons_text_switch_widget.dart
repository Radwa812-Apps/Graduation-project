
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/switch_widget.dart';
import 'package:near_me_new_version/core/constants.dart';

class IconsTextSwitchWidget extends StatefulWidget {
  const IconsTextSwitchWidget({
    super.key,
    this.showSwitch = true,
    required this.featureName,
    required this.iconData,
    this.onToggle,
    this.initialFeatureStatus = false,
    this.isLiveTrackingOn = false,
    this.id = '',
  });
  final bool initialFeatureStatus;
  final Function(bool)? onToggle;
  final bool showSwitch;
  final String? featureName;
  final IconData? iconData;
  final bool isLiveTrackingOn; // Added this parameter
  final String id; // Added this parameter

  @override
  State<IconsTextSwitchWidget> createState() => _IconsTextSwitchWidgetState();
}

class _IconsTextSwitchWidgetState extends State<IconsTextSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(widget.iconData, size: 30, color: kPrimaryColor1),
              const SizedBox(width: 10),
              Text(
                widget.featureName!,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: kFontRegular,
                  fontWeight: FontWeight.normal,
                  color: kFontColor,
                ),
              ),
            ],
          ),

          if (widget.onToggle != null)
            SwitchWidget(
              isSharingLocationPressed: true,
              onToggle: widget.onToggle,
              isLiveTrackingOn: widget.isLiveTrackingOn,
              id: widget.id,
            ),

          
        ],
      ),
    );
  }
}
