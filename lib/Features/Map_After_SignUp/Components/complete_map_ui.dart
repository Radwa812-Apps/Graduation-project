import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants.dart';
import '../../../core/services/map.dart';
import 'autoComplete_map.dart';
import 'custom_container.dart';
import 'custom_places.dart';

class CompleteMapUi extends StatefulWidget {
  const CompleteMapUi(
      {super.key,
      required this.service,
      required this.controller,
      required this.GetSearchedPlace,
      required this.goToPlace});

  final MapServices service;
  final TextEditingController controller;
  final Function(String) GetSearchedPlace;
  final Function(double, double, String) goToPlace;
  @override
  State<CompleteMapUi> createState() => _CompleteMapUiState();
}

class _CompleteMapUiState extends State<CompleteMapUi> {
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CustomContainer(
        w: 44.w,
        h: 44.h,
        child: IconButton(
          icon: Icon(
            Icons.location_on_outlined,
            color: kPrimaryColor1,
            size: 30.sp,
          ),
          onPressed: () {
            _showCustomBottomSheet(context);
          },
        ),
      ),
      CustomContainer(
        w: 230.w,
        h: 40.h,
        child: Center(
          child: AutoCompleteSearch(
            GetSearchedPlace: widget.GetSearchedPlace,
            controller: widget.controller,
            service: widget.service,
          ),
          
        ),
      ),
      

      CustomContainer(
        w: 44.w,
        h: 44.h,
        child: IconButton(
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: kPrimaryColor1,
            size: 25.sp,
          ),
          onPressed: () {},
        ),
      )
    ]);
  }

  void _showCustomBottomSheet(BuildContext context) {
    setState(() {
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setModalState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                  onPressed: (() {}),
                                  icon: const Icon(Icons.search,
                                      color: Colors.grey)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomPlacesCrudOp(
                          searchQuery: searchQuery,
                          goToPlace: widget.goToPlace,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
      });
    });
  }
}
