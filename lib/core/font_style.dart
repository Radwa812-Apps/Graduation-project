import 'package:flutter/material.dart';
import 'package:near_me_new_version/core/constants.dart';

class TextStyles {
  static const TextStyle forgotPasswordText = TextStyle(
    color: Color.fromRGBO(122, 121, 121, 1),
    fontFamily: 'Open Sans',
    fontSize: 18,
    fontWeight: FontWeight.normal,
    //height: 0,
  );

  static const TextStyle forgotPasswordButtonText = TextStyle(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontFamily: 'Open Sans',
    fontSize: 26,
    fontWeight: FontWeight.normal,
    height: 1,
  );
  static const TextStyle permissionButtonText = TextStyle(
    color: Colors.white,
    fontFamily: 'OpenSans-Bold',
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle NotificationsTilteText = TextStyle(
    color: textColor,
    fontFamily: 'OpenSans-Regular',
    fontSize: 25,
    fontWeight: FontWeight.w400,
  );
}
