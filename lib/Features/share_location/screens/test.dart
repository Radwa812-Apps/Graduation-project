import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkerMap extends StatefulWidget {
  @override
  _CustomMarkerMapState createState() => _CustomMarkerMapState();
  static String customMarkerMapScreenKey = '/CustomMarkerMapScreenKey';
}

class _CustomMarkerMapState extends State<CustomMarkerMap> {
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;
  Set<Marker> markers = {};
  LatLng initialPosition = LatLng(30.0444, 31.2357); // القاهرة كمثال

  @override
  void initState() {
    super.initState();
    //_createCustomMarker();
    //_createCircleMarker();
    _createFixedMarker();
  }

  Future<void> _createFixedMarker() async {
    customMarkerIcon = await createCircleMarkerWithImage(
      'assets/images/user_photo.jpeg',
      circleRadius: 60.0,
      circleColor: Colors.blueAccent,
      borderWidth: 4.0,
      borderColor: Colors.white,
    );
    _addMarkers();
  }

  Future<void> _createCombinedMarker() async {
    customMarkerIcon = await createCircleMarkerWithImage(
      'assets/images/user_photo.jpeg',
      circleRadius: 60.0, 
      circleColor: Colors.blueAccent,
      borderWidth: 4.0,
      borderColor: Colors.white,
    );
    _addMarkers();
  }

  Future<void> _createCustomMarker() async {
    customMarkerIcon = await createCustomMarkerWithImage(
      'assets/images/Pin_source.png',
      'assets/images/logo.png',
    );
    _addMarkers();
  }

  Future<BitmapDescriptor> createCustomMarkerWithImage(
    String pinAssetPath,
    String userAssetPath,
  ) async {
    final Uint8List pinImage = await getBytesFromAsset(pinAssetPath, 170);
    final Uint8List userImage = await getBytesFromAsset(userAssetPath, 90);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final pinCodec = await ui.instantiateImageCodec(pinImage);
    final pinFrame = await pinCodec.getNextFrame();
    canvas.drawImage(pinFrame.image, Offset.zero, Paint());

    final userCodec = await ui.instantiateImageCodec(userImage);
    final userFrame = await userCodec.getNextFrame();
    canvas.drawImage(
      userFrame.image,
      Offset(25, 10), 
      Paint(),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(150, 150);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<BitmapDescriptor> createCircleMarkerWithImage(
    String userAssetPath, {
    double circleRadius = 50.0,
    Color circleColor = Colors.blue,
    double borderWidth = 3.0,
    Color borderColor = Colors.white,
  }) async {
    final Uint8List userImage = await getBytesFromAsset(userAssetPath, 100);
    final ui.Codec userCodec = await ui.instantiateImageCodec(userImage);
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

   
    canvas.translate(0,circleRadius * 2);
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

  void _addMarkers() {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId('user_location'),
          position: initialPosition,
          icon: customMarkerIcon!,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 15,
        ),
        markers: markers,
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
      ),
    );
  }
}
