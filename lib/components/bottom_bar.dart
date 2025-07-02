import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me_new_version/core/data/bloc/profile/profile_bloc.dart';

import '../../../core/constants.dart';
import '../Features/Home/Home/components/icon_button_widegt.dart';

class BottomContainerWithIcons extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIconPressed;
  double space = 35;

  BottomContainerWithIcons({
    required this.selectedIndex,
    required this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
          color: kPrimaryColor1.withOpacity(.20),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButtonWidegt(
            onPressed: () {
              onIconPressed(0);
            },
            icon: selectedIndex == 0 ? Icons.home : Icons.home_outlined,
            size: 35,
          ),
          SizedBox(width: space),
          IconButtonWidegt(
            onPressed: () {
              BlocProvider.of<ProfileBloc>(context).add(ShowUserInfoEvent());
              onIconPressed(1);
            },
            icon: selectedIndex == 1 ? Icons.person : Icons.person_outlined,
            size: 30,
          ),
          SizedBox(width: space),
          IconButtonWidegt(
            onPressed: () {
              onIconPressed(2);
            },
            icon: selectedIndex == 2
                ? Icons.notifications
                : Icons.notifications_outlined,
            size: 30,
          ),
          SizedBox(width: space),
          // Settings Icon (Index 3)
          IconButtonWidegt(
            onPressed: () {
              onIconPressed(3);
            },
            icon: selectedIndex == 3 ? Icons.settings : Icons.settings_outlined,
            size: 30,
          ),
        ],
      ),
    );
  }
}
