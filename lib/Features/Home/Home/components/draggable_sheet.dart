import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DraggableSheetWidget extends StatefulWidget {
  final Widget child;
  final DraggableScrollableController? draggableScrollableController;

  const DraggableSheetWidget(
      {super.key, required this.child, this.draggableScrollableController});

  @override
  State<DraggableSheetWidget> createState() => _DraggableSheetWidgetState();
}

class _DraggableSheetWidgetState extends State<DraggableSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, constraints) {
      return DraggableScrollableSheet(
        controller: widget.draggableScrollableController,
        initialChildSize: 0.30.sp, 
        minChildSize: 0.25.sp, 
        maxChildSize: 0.6
            .sp, 
        expand: true,
        snap: true,
        snapSizes: [0.25.sp],
        builder: (BuildContext context, ScrollController scrollController) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 144, 195, 142)
                  .withOpacity(0.2), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                )
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: widget.child,
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
