import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/icons_text_switch_widget.dart';
import 'package:near_me_new_version/Features/group_profile/screens/media.dart';
import 'package:near_me_new_version/Features/select_place/screens/select_place_screen.dart';

class FeaturesOne extends StatefulWidget {
  final Function(bool)? onToggle;
  final bool isLiveTrackingOn;
  final String id;
 
  const FeaturesOne({
    this.onToggle,
    super.key,
    this.isLiveTrackingOn = false,
    this.id = '',
  });
  @override
  State<FeaturesOne> createState() => _FeaturesOneState();
}

class _FeaturesOneState extends State<FeaturesOne> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const IconsTextSwitchWidget(
          iconData: Icons.notifications_outlined,
          featureName: 'Notifications',
        ),
        const SizedBox(height: 20),
        IconsTextSwitchWidget(
          id: widget.id,
          iconData: Icons.location_on_outlined,
          featureName: 'Share Location',
          onToggle: (value) {
            // هنا تقدر تطبع قيمة الـ onToggle في اللوج
            print("onToggle value: $value");
            if (widget.onToggle != null) {
              widget.onToggle!(value);
            }
          },
          isLiveTrackingOn: widget.isLiveTrackingOn,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPlaceScreen(groupId: widget.id),
              ),
            );
          },
          child: const IconsTextSwitchWidget(
            iconData: Icons.select_all_rounded,
            featureName: 'Select Places',
            showSwitch: false,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, MediaScreen.mediaScreenKey);
          },
          child: const IconsTextSwitchWidget(
            iconData: Icons.image_outlined,
            featureName: 'Media',
            showSwitch: false,
          ),
        ),
      ],
    );
  }
}
