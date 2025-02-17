
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextBar extends StatelessWidget {
  final TextEditingController controller;
  final Function onSubmitted;
  final Function onCancel;

  const TextBar({
    required this.controller,
    required this.onSubmitted,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter place name',
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                onSubmitted();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              onCancel();
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              onSubmitted();
            },
          ),
        ],
      ),
    );
  }
}

