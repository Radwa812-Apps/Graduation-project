import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Marker> createCustomUserMarker({
  required String pinImagePath,
  required String userImagePath,
  required LatLng position,
  int pinWidth = 150,
  int userWidth = 100,
}) async {
  // Load the images as bytes
  final Uint8List pinImage = await _getBytesFromAsset(pinImagePath, pinWidth);
  final Uint8List userImage = await _getBytesFromAsset(
    userImagePath,
    userWidth,
  );

  // Create the BitmapDescriptor
  final BitmapDescriptor markerIcon = await _createCustomMarkerWithImage(
    pinImage,
    userImage,
  );

  // Return the marker
  return Marker(
    markerId: MarkerId(
      'custom_user_marker_${position.latitude}_${position.longitude}',
    ),
    position: position,
    icon: markerIcon,
  );
}

// Helper to load asset image
Future<Uint8List> _getBytesFromAsset(String path, int width) async {
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

// Helper to draw pin + user image into one
Future<BitmapDescriptor> _createCustomMarkerWithImage(
  Uint8List pinImage,
  Uint8List userImage,
) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  final pinCodec = await ui.instantiateImageCodec(pinImage);
  final pinFrame = await pinCodec.getNextFrame();
  canvas.drawImage(pinFrame.image, Offset.zero, ui.Paint());

  final userCodec = await ui.instantiateImageCodec(userImage);
  final userFrame = await userCodec.getNextFrame();

  // Adjust user image position here if needed
  canvas.drawImage(
    userFrame.image,
    const Offset(25, 10), // Modify as needed
    ui.Paint(),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(150, 150);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(bytes);
}
