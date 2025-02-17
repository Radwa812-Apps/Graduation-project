import 'package:flutter/material.dart';

Future<void> selectDate(
    BuildContext context, TextEditingController dateController) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );
  if (picked != null && picked != DateTime.now()) {
    dateController.text = picked.toString().split(' ')[0];
  }
}
