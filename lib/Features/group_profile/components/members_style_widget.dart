import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Private_chat/screens/private_chat_screen.dart';
import '../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';

class MembersStyleWidget extends StatelessWidget {
  final String? userName;

  const MembersStyleWidget({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: (() {
        Navigator.pushNamed(
          context,
          PrivateChatScreen.privateChatScreenKey,
          arguments: userName,
        );
      }),
      child: Container(
        width: screenWidth * .96,
        height: screenHeight * .08,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: kPrimaryColor1.withOpacity(.20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: RoundImageWidget(
                    name: kDefaultUserImge,
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  userName!,
                  style: const TextStyle(
                    color: kFontColor,
                    fontSize: 20,
                    fontFamily: kFontRegular,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
