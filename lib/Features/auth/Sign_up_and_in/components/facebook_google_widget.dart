import 'package:flutter/material.dart';


class FacebookGoogleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(width: 40),
        SizedBox(
          width: 55, 
          height: 55, 
          child: Image(
            image: AssetImage('assets/images/facebook.png'),
            fit: BoxFit.contain, 
          ),
        ),
      ],
    );
  }
}
