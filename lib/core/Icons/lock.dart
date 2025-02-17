import 'package:flutter/material.dart';


class Lock extends StatelessWidget {
  final double top;
  final double left;

  const Lock({
    super.key,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: const Icon(Icons.lock_outlined,color:Color.fromRGBO(61, 83, 0, 1),),
    );
  }
}

 