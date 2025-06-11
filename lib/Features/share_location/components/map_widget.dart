import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:near_me_new_version/Features/share_location/components/location_controller.dart';
import 'package:near_me_new_version/Features/share_location/components/map_controller.dart';

class MapWidget extends StatelessWidget {
  final bool isLiveTrackingOn;
  final LocationData? currentLocation;
  final LocationData? destinationLocation;
  final LocationData? sourceLocation;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;
  final Set<Polyline> polylines;
  final MapController mapController;

  const MapWidget({
    super.key,
    required this.isLiveTrackingOn,
    required this.currentLocation,
    required this.destinationLocation,
    required this.sourceLocation,
    required this.markers,
    required this.onMapCreated,
    required this.polylines,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLiveTrackingOn) {
      log("building live tracking map");

      return _buildLiveTrackingMap();
    } else {
      log("building static map");
      return _buildStaticMap();
    }
  }

  Widget _buildLiveTrackingMap() {
    log("Current Location: $currentLocation");
    log("Destination Location: $destinationLocation");

    if (currentLocation == null || destinationLocation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading"),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        zoom: 13.5,
      ),
      markers: markers,
      onMapCreated: onMapCreated,
      polylines: polylines,
    );
  }

  Widget _buildStaticMap() {
    //final MapController _mapController = MapController();

    log("markers: $markers");
    log("initial position: ${mapController.initialPosition}");
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: mapController.initialPosition,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('My_location'),
          position: mapController.initialPosition,
          infoWindow: const InfoWindow(title: 'your Location'),
        ),
      },
      onMapCreated: onMapCreated,
    );
  }
}
