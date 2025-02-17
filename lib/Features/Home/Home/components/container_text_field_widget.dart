import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Home/Home/components/draggable_sheet.dart';

import '../../../../core/constants.dart';

class ContainerTextFieldWidget extends StatefulWidget {
  final VoidCallback onTextFieldFocus;
  final DraggableScrollableController draggableScrollableController;
  final Function(String) onSubmitted;

  const ContainerTextFieldWidget({
    super.key,
    required this.onTextFieldFocus,
    required this.draggableScrollableController,
    required this.onSubmitted,
  });

  @override
  _ContainerTextFieldWidgetState createState() =>
      _ContainerTextFieldWidgetState();
}

class _ContainerTextFieldWidgetState extends State<ContainerTextFieldWidget> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: DraggableSheetWidget(
        draggableScrollableController: widget.draggableScrollableController,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _textEditingController,
                      onTap: widget.onTextFieldFocus,
                      style: TextStyle(
                        color: kFontColor,
                        fontSize: 18.sp,
                        fontFamily: kFontItalic,
                        fontStyle: FontStyle.italic,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () => _textEditingController.clear(),
                          icon: const Icon(
                            Icons.close,
                            color: kFontColor,
                          ),
                        ),
                        hintText: 'Group Name',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 18.sp,
                          fontFamily: kFontItalic,
                          fontStyle: FontStyle.italic,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 20.h),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  )),
                ],
              ),
              SizedBox(height: 30.h),
              Container(
                width: 90.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color: kSpecialColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {
                    final groupName = _textEditingController.text.trim();
                    if (groupName.isNotEmpty) {
                      widget.onSubmitted(groupName);
                      _textEditingController.clear();
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
