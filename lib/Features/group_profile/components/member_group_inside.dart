import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';
import '../../../core/constants.dart';
import '../../Home/Home/components/round_image_widget.dart';

class MemberGroupInside extends StatefulWidget {
  final String userName;
  final String status;
  final String distance;
  final bool isOwner;
  final String picture;
  final String uid;

  const MemberGroupInside({
    super.key,
    required this.userName,
    required this.status,
    required this.distance,
    this.isOwner = false,
    required this.picture,
    required this.uid,
  });

  @override
  State<MemberGroupInside> createState() => _MemberGroupInsideState();
}

class _MemberGroupInsideState extends State<MemberGroupInside> {
  Uint8List? userImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserImage());
  }

  Future<void> _loadUserImage() async {
    if (_isLoading || widget.uid.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      final image = await ProfileImageService().getDecryptedUserImage(
        widget.uid,
      );
      if (image != null && mounted) setState(() => userImage = image);
    } catch (e, stackTrace) {
      developer.log(
        'Error loading user image',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد حجم الشاشة
        final bool isSmallScreen = constraints.maxWidth < 400;
        final bool isMediumScreen =
            constraints.maxWidth >= 400 && constraints.maxWidth < 600;

        // ضبط الأحجام بشكل ديناميكي
        final double containerHeight =
            isSmallScreen
                ? 70.h
                : isMediumScreen
                ? 75.h
                : 80.h;
        final double imageSize =
            isSmallScreen
                ? 45.w
                : isMediumScreen
                ? 48.w
                : 50.w;
        final double nameFontSize =
            isSmallScreen
                ? 15.sp
                : isMediumScreen
                ? 16.sp
                : 17.sp;
        final double statusFontSize =
            isSmallScreen
                ? 13.sp
                : isMediumScreen
                ? 14.sp
                : 15.sp;
        final double ownerFontSize = isSmallScreen ? 9.sp : 10.sp;
        final double horizontalPadding = isSmallScreen ? 12.w : 16.w;
        final double borderWidth = isSmallScreen ? 0.8.w : 1.w;

        return Container(
          height: containerHeight,
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: kPrimaryColor1, width: borderWidth),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: horizontalPadding),
                child:
                    _isLoading
                        ? SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: CircularProgressIndicator(
                            color: kPrimaryColor1,
                            strokeWidth: 2,
                          ),
                        )
                        : RoundImageWidget(
                          imageBytes: userImage,
                          width: imageSize,
                          height: imageSize,
                        ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.userName,
                              style: TextStyle(
                                color: kFontColor,
                                fontSize: nameFontSize,
                                fontFamily: kFontRegular,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (widget.isOwner) ...[
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: kPrimaryColor1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'Owner',
                                style: TextStyle(
                                  color: kPrimaryColor1,
                                  fontSize: ownerFontSize,
                                  fontFamily: kFontRegular,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.status,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: statusFontSize,
                          fontFamily: kFontRegular,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
