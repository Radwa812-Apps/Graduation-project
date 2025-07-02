import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:near_me_new_version/core/constants.dart';

class MapServices {
  final Dio dio;
  final MapApiKey = goMapsApiKey;//"AlzaSyetuGJZzPCNKSqqTJtLrakppsC7JOzCSxC";
  String inputType = 'textquery';
  MapServices(this.dio);
  LatLng? latLng;
  final String domain = "https://maps.gomaps.pro/maps/api/place/";
  Future<LatLng?> getPlaceLatLng(String placeName) async {
    if (RegExp(r'^\d+$').hasMatch(placeName)) {
      inputType = "phonenumber";
    } else {
      inputType = "textquery";
    }

    try {
      Response response = await dio.get(
          '${domain}findplacefromtext/json?fields=formatted_address,geometry&input=$placeName&inputtype=$inputType&key=$MapApiKey');

      Map<String, dynamic> jsonData = response.data;
      log(jsonEncode(jsonData));
      List<dynamic> candidates = jsonData['candidates'];
      log('candidates: ${jsonEncode(candidates)}');
      for (var can in candidates) {
        var geometry = can['geometry'];
        if (geometry != null) {
          var location = geometry['location'];
          log(jsonEncode(location));
          if (location != null) {
            double? lat = location['lat']?.toDouble();
            double? lng = location['lng']?.toDouble();
            if (lat != null && lng != null) {
              latLng = LatLng(lat, lng);
              log('Latitude: ${latLng!.latitude}, Longitude: ${latLng!.longitude}');
            }
          }
        }
      }

      return latLng!;
    } on DioError catch (e) {
      log(getDioErrorMessage(e));
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  List<String> suggestions = [];
  Future<List<String>?> handleAutoCompleteSearch(String search) async {
    try {
      suggestions.clear();
      Response response = await dio.get(
          '${domain}queryautocomplete/json?input=${search}&key=${MapApiKey}');

      Map<String, dynamic> jsonData = response.data;
      log(jsonEncode(jsonData));
      List<dynamic> predictions = jsonData['predictions'];
      log(jsonEncode(predictions));
      for (var pred in predictions) {
        var description = pred['description'];
        if (description != null) {
          log(description);
          suggestions.add(description);
        }
      }
      return suggestions;
    } on DioError catch (e) {
      log(getDioErrorMessage(e));
    } catch (e) {
      log('Error handleAutoCompleteSearch: $e');
    }
    return null;
  }
List<LatLng> polylineCoordinates = [];

Future<List<LatLng>?> getPolyPoints(LocationData sourceLocation, LocationData destination) async {
  final url = Uri.parse('https://routes.gomaps.pro/directions/v2:computeRoutes');
  
  final headers = {
    'Content-Type': 'application/json',
    'x-goog-api-key': goMapsApiKey,
    'x-goog-fieldmask': '*',
  };
  
  final body = jsonEncode({
  "origin": {
    "location": {
      "latLng": {
        "latitude": sourceLocation.latitude,
        "longitude": sourceLocation.longitude
      }
    }
  },
  "destination": {
    "location": {
      "latLng": {
        "latitude": destination.latitude,
        "longitude": destination.longitude
      }
    }
  },
  "travelMode": "DRIVE"
});

  try {
    final response = await http.post(url, headers: headers, body: body);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final encodedPolyline = data['routes'][0]['legs'][0]['polyline']['encodedPolyline'];
      
      polylineCoordinates = _decodePolyline(encodedPolyline);
      return polylineCoordinates;
    } else {
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
List<LatLng> _decodePolyline(String encoded) {
  List<LatLng> points = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}
  String getDioErrorMessage(DioError e) {
    if (e.type == DioErrorType.response) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode == 400) {
          return "bad request. try again later";
        } else if (statusCode == 401) {
          return "user unauthorized, try again later";
        } else if (statusCode == 403) {
          return "forbidden request. try again later";
        } else if (statusCode == 404) {
          return "url not found, try again later";
        } else if (statusCode == 409) {
          return "conflict found, try again later";
        } else if (statusCode == 500) {
          return "internal server error, try again later";
        } else {
          return "some thing went wrong, try again later";
        }
      } else {
        return "bad response, but no details available";
      }
    } else if (e.type == DioErrorType.connectTimeout ||
        e.type == DioErrorType.receiveTimeout ||
        e.type == DioErrorType.sendTimeout) {
      return "time out, try again later";
    } else if (e.type == DioErrorType.other) {
      if (e.error is SocketException) {
        return "Please check your internet connection";
      } else {
        return "unknown error, try again later";
      }
    } else if (e.type == DioErrorType.cancel) {
      return "request cancelled";
    } else if (e.type == DioErrorType.other) {
      return "bad certificate, try again later";
    } else {
      return "default_error: some thing went wrong, try again later";
    }
  }
}
