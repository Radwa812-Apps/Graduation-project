import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Map_After_SignUp/Components/custom_container.dart';

import '../../../core/constants.dart';

class MessageBox extends StatelessWidget {
  final VoidCallback onClose;

  const MessageBox({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Stack(
        children: [
          const CustomContainer(
            w: 60,
            h: 40,
            child: Text(
              'Tap on the map to add your place',
              style: TextStyle(
                fontSize: 16,
                color: kPrimaryColor1,
                fontFamily: 'OpenSans-Bold',
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onClose,
              child: const Icon(
                Icons.close,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
