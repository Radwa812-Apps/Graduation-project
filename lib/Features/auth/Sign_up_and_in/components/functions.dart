import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants.dart';

Future<void> selectDate(BuildContext context, TextEditingController dateController, Function(String) onDateSelected) async {
  final selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme:  const ColorScheme.light(
            primary: kSpecialColor,
            onPrimary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: kSpecialColor, 
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (selectedDate != null) {
    final formattedDate =
        "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";
    dateController.text = formattedDate;
    onDateSelected(formattedDate); 
  }
}