import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../components/mainScaffold.dart';
import '../../../core/constants.dart';

class SkipBtn extends StatelessWidget {
  const SkipBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: kSpecialColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.zero,
            minimumSize: const Size(10, 40)),
        onPressed: () {
        // Navigator.pushNamed(context, HomeScreen.homeScreenKey);
         // Navigator.pushNamed(context, MainScaffold.mainScaffoldKey);
         Navigator.pushReplacementNamed(context, MainScaffold.mainScaffoldKey);
        },
        child: const Text(
          'Skip',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ));
  }
}
