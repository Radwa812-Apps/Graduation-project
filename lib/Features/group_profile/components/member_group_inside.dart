import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';

class MemberGroupInside extends StatelessWidget {
  const MemberGroupInside({
    super.key,
    required this.userName,
    required this.lastLocatin,
    required this.distance,
  });

  final String userName;
  final String lastLocatin;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity, 
      decoration: BoxDecoration(
        border: Border.all(
          color: kPrimaryColor1, 
          width: 1, 
        ),
        borderRadius: BorderRadius.circular(30), 
        boxShadow: const [
          BoxShadow(
            color: kBackgroundColor, 
            blurRadius: 10, 
            spreadRadius: 2,
            offset: Offset(0, 0), 
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, 
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: RoundImageWidget(
              name: kDefaultUserImge,
              width: 50,
              height: 50,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: kFontColor,
                    fontSize: 20,
                    fontFamily: kFontRegular,
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  lastLocatin,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontFamily: kFontRegular,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(), 
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              distance,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontFamily: kFontRegular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
