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
    _createCustomMarker();
  }

  Future<void> _createCustomMarker() async {
    customMarkerIcon = await createCustomMarkerWithImage(
      'assets/location_pin.png', 
      'assets/user_photo.jpg'
    );
    _addMarkers();
  }

  Future<BitmapDescriptor> createCustomMarkerWithImage(
    String pinAssetPath, 
    String userAssetPath
  ) async {
    final Uint8List pinImage = await getBytesFromAsset(pinAssetPath, 150);
    final Uint8List userImage = await getBytesFromAsset(userAssetPath, 100);
    
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    
    // رسم دبوس الموقع
    final pinCodec = await ui.instantiateImageCodec(pinImage);
    final pinFrame = await pinCodec.getNextFrame();
    canvas.drawImage(pinFrame.image, Offset.zero, Paint());
    
    // رسم صورة المستخدم في المنتصف
    final userCodec = await ui.instantiateImageCodec(userImage);
    final userFrame = await userCodec.getNextFrame();
    canvas.drawImage(
      userFrame.image, 
      Offset(25, 10), // تعديل الموقع حسب التصميم
      Paint()
    );
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(150, 150);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(), 
      targetWidth: width
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
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