import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/map.dart';
import '../Components/autoComplete_map.dart';

class Map1shimaa extends StatefulWidget {
  const Map1shimaa({super.key});

  @override
  State<Map1shimaa> createState() => _Map1shimaaState();
}

class _Map1shimaaState extends State<Map1shimaa> {
  bool isTextBarVisible = false;
  String? markerLabelCustomPlaceName;
  final TextEditingController _textBarController = TextEditingController();

  LatLng? selectedLatLng;

  Set<Marker> markers = {};
  MapServices service = MapServices(Dio());
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static const CameraPosition _Assuit = CameraPosition(
    target: LatLng(27.18096, 31.18368),
    zoom: 14.4746,
  );
  final String _googleAPIKey = "AIzaSyAC_AFu3lh7dP-a_Ffj4JZFeqmK_fGkNwo";
  // ignore: prefer_typing_uninitialized_variables
  var onCreatedmapController;
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onTap: (latLng) {
              setState(() {
                selectedLatLng = latLng;
              });
            },
            markers: markers,
            mapType: MapType.normal,
            initialCameraPosition: _Assuit,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              onCreatedmapController = controller;
            },
          ),
          Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: AutoCompleteSearch(
                GetSearchedPlace: GetSearchedPlace,
                controller: controller,
                service: service,
              ))
        ],
      ),
    );
  }

  Future<void> GetSearchedPlace(String value) async {
    markers.clear();
    LatLng? searchedPlaceLatLng = await service.getPlaceLatLng(value);
    log(searchedPlaceLatLng.toString());
    if (searchedPlaceLatLng != null) {
      onCreatedmapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  searchedPlaceLatLng.latitude, searchedPlaceLatLng.longitude),
              zoom: 17.0)));
      setState(() {
        markers.add(Marker(
            markerId: MarkerId(searchedPlaceLatLng.toString()),
            draggable: false,
            position: LatLng(
                searchedPlaceLatLng.latitude, searchedPlaceLatLng.longitude)));
      });
    } else {
      log('no searched place');
    }
  }

  
}
