import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:near_me_new_version/core/services/profile_image_service.dart';

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: width,
  );
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
}

Future<BitmapDescriptor> createCircleMarkerWithImage(
  Uint8List userImage, {
  double circleRadius = 50.0,
  Color circleColor = Colors.blue,
  double borderWidth = 3.0,
  Color borderColor = Colors.white,
}) async {
  //String id = FirebaseAuth.instance.currentUser!.uid;
  //final decrypted = await ProfileImageService().getDecryptedUserImage(id);
  // 1. تحميل صورة المستخدم
  //final Uint8List userImage = await getBytesFromAsset(userAssetPath, 100);
  final ui.Codec userCodec = await ui.instantiateImageCodec(userImage!);
  final ui.FrameInfo userFrame = await userCodec.getNextFrame();
  final ui.Image image = userFrame.image;

  // 2. إنشاء Canvas لرسم العلامة
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // 3. حساب أبعاد الصورة داخل الدائرة
  final double imageSize = (circleRadius - borderWidth) * 1.9;
  final double imageOffset = circleRadius - (imageSize / 2);

  // 4. رسم الدائرة الأساسية
  final Paint circlePaint = Paint()..color = circleColor;
  canvas.drawCircle(
    Offset(circleRadius, circleRadius),
    circleRadius,
    circlePaint,
  );

  // 5. رسم حدود الدائرة
  final Paint borderPaint =
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
  canvas.drawCircle(
    Offset(circleRadius, circleRadius),
    circleRadius - (borderWidth / 2),
    borderPaint,
  );

  // 6. حفظ حالة Canvas الحالية
  canvas.save();

  // 7. تطبيق تحويل لتصحيح اتجاه الصورة
  canvas.translate(0, circleRadius * 2);
  canvas.scale(1.0, -1.0); // عكس الصورة أفقياً

  // 8. قص الصورة بشكل دائري
  final Path clipPath =
      Path()..addOval(
        Rect.fromCircle(
          center: Offset(circleRadius, circleRadius),
          radius: circleRadius - borderWidth,
        ),
      );
  canvas.clipPath(clipPath);

  // 9. رسم الصورة مع التصحيح
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromLTWH(
      circleRadius - imageSize / 2,
      circleRadius - imageSize / 2,
      imageSize,
      imageSize,
    ),
    Paint()..filterQuality = FilterQuality.high,
  );

  // 10. استعادة حالة Canvas السابقة
  canvas.restore();

  // 11. تحويل الرسم إلى BitmapDescriptor
  final ui.Picture picture = recorder.endRecording();
  final ui.Image markerImage = await picture.toImage(
    (circleRadius * 2).toInt(),
    (circleRadius * 2).toInt(),
  );
  final ByteData? byteData = await markerImage.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}

Future<BitmapDescriptor?> imageToBitmapDescriptor({
  int targetWidth = 100,
}) async {
  String imagePath = "assets/images/destination.jpeg";
  // 1. قراءة ملف الصورة من المسار المحدد
  final File imageFile = File(imagePath);

  if (!await imageFile.exists()) {
    log('Image file not found at path: $imagePath');
    return null;
  }

  // 2. تحميل الصورة كـ bytes
  final Uint8List imageBytes = await imageFile.readAsBytes();

  // 3. فك تشفير الصورة وتغيير حجمها
  final ui.Codec codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: targetWidth,
  );

  final ui.FrameInfo frame = await codec.getNextFrame();

  // 4. تحويل الصورة إلى تنسيق PNG
  final ByteData? byteData = await frame.image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  if (byteData == null) {
    log('Failed to convert image to byte data');
  }

  // 5. إنشاء BitmapDescriptor من البايتات
  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}


Future<BitmapDescriptor> createCircleMarkerWithDefaultImage(
  String userAssetPath, {
  double circleRadius = 50.0,
  Color circleColor = Colors.blue,
  double borderWidth = 3.0,
  Color borderColor = Colors.white,
}) async {
  //String id = FirebaseAuth.instance.currentUser!.uid;
  //final decrypted = await ProfileImageService().getDecryptedUserImage(id);
  // 1. تحميل صورة المستخدم
  final Uint8List userImage = await getBytesFromAsset(userAssetPath, 100);
  final ui.Codec userCodec = await ui.instantiateImageCodec(userImage!);
  final ui.FrameInfo userFrame = await userCodec.getNextFrame();
  final ui.Image image = userFrame.image;

  // 2. إنشاء Canvas لرسم العلامة
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // 3. حساب أبعاد الصورة داخل الدائرة
  final double imageSize = (circleRadius - borderWidth) * 1.9;
  final double imageOffset = circleRadius - (imageSize / 2);

  // 4. رسم الدائرة الأساسية
  final Paint circlePaint = Paint()..color = circleColor;
  canvas.drawCircle(
    Offset(circleRadius, circleRadius),
    circleRadius,
    circlePaint,
  );

  // 5. رسم حدود الدائرة
  final Paint borderPaint =
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
  canvas.drawCircle(
    Offset(circleRadius, circleRadius),
    circleRadius - (borderWidth / 2),
    borderPaint,
  );

  // 6. حفظ حالة Canvas الحالية
  canvas.save();

  // 7. تطبيق تحويل لتصحيح اتجاه الصورة
  canvas.translate(0, circleRadius * 2);
  canvas.scale(1.0, -1.0); // عكس الصورة أفقياً

  // 8. قص الصورة بشكل دائري
  final Path clipPath =
      Path()..addOval(
        Rect.fromCircle(
          center: Offset(circleRadius, circleRadius),
          radius: circleRadius - borderWidth,
        ),
      );
  canvas.clipPath(clipPath);

  // 9. رسم الصورة مع التصحيح
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromLTWH(
      circleRadius - imageSize / 2,
      circleRadius - imageSize / 2,
      imageSize,
      imageSize,
    ),
    Paint()..filterQuality = FilterQuality.high,
  );

  // 10. استعادة حالة Canvas السابقة
  canvas.restore();

  // 11. تحويل الرسم إلى BitmapDescriptor
  final ui.Picture picture = recorder.endRecording();
  final ui.Image markerImage = await picture.toImage(
    (circleRadius * 2).toInt(),
    (circleRadius * 2).toInt(),
  );
  final ByteData? byteData = await markerImage.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
