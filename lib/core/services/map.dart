import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapServices {
  final Dio dio;
  final MapApiKey = "AlzaSyetuGJZzPCNKSqqTJtLrakppsC7JOzCSxC";
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
