import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';

class RowCheckbox extends StatefulWidget {
  final String? userName;
  final Function(bool)? onChanged;
  final bool initialValue; // ضفنا ده عشان نتحكم في القيمة الابتدائية

  const RowCheckbox({
    super.key,
    this.userName,
    this.onChanged,
    this.initialValue = false, // قيمة افتراضية
  });

  @override
  _RowCheckboxState createState() => _RowCheckboxState();
}

class _RowCheckboxState extends State<RowCheckbox> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialValue; // البداية بناءً على القيمة اللي جاية
  }

  @override
  Widget build(BuildContext context) {
    log("RowCheckbox build called, isChecked: $isChecked");
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              isChecked
                  ? kPrimaryColor1.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.5),
          width: 1.5,
        ),
        color: isChecked ? kPrimaryColor1.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 176, 238, 178).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            setState(() {
              isChecked = !isChecked;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(isChecked);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const RoundImageWidget(
                  //name: kDefaultGroupImge,
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 20),
                Text(
                  widget.userName ?? 'Unknown',
                  style: const TextStyle(
                    color: kFontColor,
                    fontSize: 20,
                    fontFamily: kFontRegular,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isChecked ? kPrimaryColor1 : Colors.transparent,
                    border: Border.all(
                      color: isChecked ? kPrimaryColor1 : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child:
                      isChecked
                          ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                          : null,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
