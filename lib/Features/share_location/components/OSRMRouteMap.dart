import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart' as latLng;

class OSRMRouteMap {
  Dio dio = Dio();
  Future<List<latLng.LatLng>> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    List<latLng.LatLng> polylinePoints = [];
    String url =
        "https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;

      final coords = data['routes'][0]['geometry']['coordinates'];

      polylinePoints =
          coords
              .map<latLng.LatLng>((point) => latLng.LatLng(point[1], point[0]))
              .toList();
      return polylinePoints;
    } else {
      print("Failed to load route");
      throw Exception("Failed to load route");
    }
  }
}
