import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/group_profile/components/switch_widget.dart';

import '../../../core/constants.dart';

class IconsTextSwitchWidget extends StatelessWidget {
  const IconsTextSwitchWidget({
    super.key,
    this.showSwitch = true,
    required this.featureName,
    required this.iconData,
  });

  final bool showSwitch;
  final String? featureName;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                iconData,
                size: 30,
                color: kPrimaryColor1,
              ),
              const SizedBox(width: 10),
              Text(
                featureName!,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: kFontRegular,
                  fontWeight: FontWeight.normal,
                  color: kFontColor,
                ),
              ),
            ],
          ),
          if (showSwitch)
            const SwitchWidget(), 
        ],
      ),
    );
  }
}
