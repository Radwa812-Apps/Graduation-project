import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';
import '../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';
import '../../Private_chat/Private_chat/screens/private_chat_screen.dart';

class MembersStyleWidget extends StatefulWidget {
  final String? userName;
  final String? picture;
  final String? uid;

  const MembersStyleWidget({super.key, required this.userName,this.picture,this.uid});

  @override
  State<MembersStyleWidget> createState() => _MembersStyleWidgetState();
}

class _MembersStyleWidgetState extends State<MembersStyleWidget> {
  @override
  void initState() {
    super.initState();
    _loadUserImage();
  }
  Uint8List? userImage;
  void _loadUserImage() async {
    if (widget.uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not authenticated"),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    if (widget.uid != null) {
      final image = await ProfileImageService().getDecryptedUserImage(widget.uid!);
      if (image != null && mounted) {
        setState(() {
          userImage = image;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: (() {
        Navigator.pushNamed(
          context,
          PrivateChatScreen.privateChatScreenKey,
          arguments: widget.userName,
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
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: RoundImageWidget(
                    imageBytes: userImage ,
                    //name: kDefaultUserImge,
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  widget.userName!,
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
