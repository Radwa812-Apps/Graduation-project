import 'package:flutter/material.dart';

class NearMeGradientColor extends StatelessWidget {
  @override
  Widget build(Object context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(34, 55, 33, 1),
            Color.fromRGBO(40, 66, 39, 1),
            Color.fromRGBO(47, 77, 46, 1),
            Color.fromRGBO(54, 88, 52, 1),
            Color.fromRGBO(61, 99, 59, 1),
            Color.fromRGBO(68, 110, 66, 1),
            Color.fromRGBO(86, 124, 84, 1),
            Color.fromRGBO(105, 139, 103, 1),
            Color.fromRGBO(124, 153, 122, 1),
            Color.fromRGBO(142, 168, 141, 1),
            Color.fromRGBO(161, 182, 160, 1),
          ],
          stops: [
            0.0, 
            0.1, 
            0.2, 
            0.3, 
            0.4, 
            0.5, 
            0.6, 
            0.7, 
            0.8, 
            0.9, 
            1.0, 
          ],
        ),
      ),
    );
  }
}
