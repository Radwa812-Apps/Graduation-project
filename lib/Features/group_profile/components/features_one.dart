import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/icons_text_switch_widget.dart';
import 'package:near_me_new_version/Features/group_profile/screens/media.dart';
import 'package:near_me_new_version/Features/select_place/screens/select_place_screen.dart';

class FeaturesOne extends StatelessWidget {
  const FeaturesOne({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const IconsTextSwitchWidget(
          iconData: Icons.notifications_outlined,
          featureName: 'Notifications',
        ),
        const SizedBox(height: 20),
        const IconsTextSwitchWidget(
          iconData: Icons.location_on_outlined,
          featureName: 'Share Location',
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                context, SelectPlaceScreen.selectPlaceScreenKey);
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
