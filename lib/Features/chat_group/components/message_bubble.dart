import 'package:flutter/material.dart';

import '../../../core/constants.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 10, left: 80), 
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7, 
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFD0D8BA), 
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: textColor,fontFamily: 'OpenSans-Regular',fontWeight:FontWeight.w400),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: textColor,fontFamily:  'OpenSans-Regular',fontWeight:FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
