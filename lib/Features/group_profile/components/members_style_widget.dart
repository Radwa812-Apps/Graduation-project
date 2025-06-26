import 'dart:developer';
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

  const MembersStyleWidget({
    super.key, 
    required this.userName,
    this.picture,
    this.uid,
  });

  @override
  State<MembersStyleWidget> createState() => _MembersStyleWidgetState();
}

class _MembersStyleWidgetState extends State<MembersStyleWidget> {
  Uint8List? userImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserImage());
  }

  void _loadUserImage() async {
    if (widget.uid == null || widget.uid!.isEmpty) return;
    
    final image = await ProfileImageService().getDecryptedUserImage(widget.uid!);
    if (image != null && mounted) {
      setState(() {
        userImage = image;
      });
    }
  }

  void _navigateToPrivateChat() {
    if (widget.uid == null || widget.userName == null) return;
    
    Navigator.pushNamed(
      context,
      PrivateChatScreen.privateChatScreenKey,
      arguments: {
        'recipientId': widget.uid!,
        'recipientName': widget.userName!,
        'recipientImage': widget.picture,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    log("MembersStyleWidget build called, userName: ${widget.userName}, uid: ${widget.uid}");
    return GestureDetector(
      onTap: _navigateToPrivateChat, // Updated to use the new navigation method
      child: Container(
        width: MediaQuery.of(context).size.width * .96,
        height: MediaQuery.of(context).size.height * .08,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: kPrimaryColor1.withOpacity(.20),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: RoundImageWidget(
                imageBytes: userImage,
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              widget.userName ?? 'Unknown User',
              style: const TextStyle(
                color: kFontColor,
                fontSize: 20,
                fontFamily: kFontRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}