import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapController {
  GoogleMapController? mapController;
  bool isMapReady = false;
  LatLng initialPosition = LatLng(30.0444, 31.2357);
  Set<Marker> markers = {};

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapReady = true;
  }

  void updateCameraPosition(LatLng position, {double zoom = 14.0}) {
    log("Updating camera position to: $position with zoom: $zoom");
    try {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: zoom),
        ),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void updateMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
  }

  void dispose() {
    mapController?.dispose();
  }
}
