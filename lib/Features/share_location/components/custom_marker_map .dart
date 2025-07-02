import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


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
  
  final ui.Codec userCodec = await ui.instantiateImageCodec(userImage!);
  final ui.FrameInfo userFrame = await userCodec.getNextFrame();
  final ui.Image image = userFrame.image;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final double imageSize = (circleRadius - borderWidth) * 1.9;
  final double imageOffset = circleRadius - (imageSize / 2);
  final Paint circlePaint = Paint()..color = circleColor;
  canvas.drawCircle(
    Offset(circleRadius, circleRadius),
    circleRadius,
    circlePaint,
  );
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

  canvas.save();
  canvas.translate(0, circleRadius * 2);
  canvas.scale(1.0, -1.0); 
  final Path clipPath =
      Path()..addOval(
        Rect.fromCircle(
          center: Offset(circleRadius, circleRadius),
          radius: circleRadius - borderWidth,
        ),
      );
  canvas.clipPath(clipPath);
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
  canvas.restore();
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
  final File imageFile = File(imagePath);

  if (!await imageFile.exists()) {
    log('Image file not found at path: $imagePath');
    return null;
  }
  final Uint8List imageBytes = await imageFile.readAsBytes();
  final ui.Codec codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: targetWidth,
  );

  final ui.FrameInfo frame = await codec.getNextFrame();

  final ByteData? byteData = await frame.image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  if (byteData == null) {
    log('Failed to convert image to byte data');
  }

  return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
}

Future<BitmapDescriptor> createCircleMarkerWithDefaultImage(
  String userAssetPath, {
  double circleRadius = 50.0,
  Color circleColor = Colors.blue,
  double borderWidth = 3.0,
  Color borderColor = Colors.white,
}) async {
  final Uint8List userImage = await getBytesFromAsset(userAssetPath, 100);
  final ui.Codec userCodec = await ui.instantiateImageCodec(userImage!);
  final ui.FrameInfo userFrame = await userCodec.getNextFrame();
  final ui.Image image = userFrame.image;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);


  final double imageSize = (circleRadius - borderWidth) * 1.9;
  final double imageOffset = circleRadius - (imageSize / 2);


  final Paint circlePaint = Paint()..color = circleColor;
  canvas.drawCircle(
    Offset(circleRadius, circleRadius),
    circleRadius,
    circlePaint,
  );

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

  canvas.save();

  canvas.translate(0, circleRadius * 2);
  canvas.scale(1.0, -1.0); 

  final Path clipPath =
      Path()..addOval(
        Rect.fromCircle(
          center: Offset(circleRadius, circleRadius),
          radius: circleRadius - borderWidth,
        ),
      );
  canvas.clipPath(clipPath);
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

  canvas.restore();

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
