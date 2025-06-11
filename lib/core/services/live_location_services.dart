import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
//   import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:location/location.dart';

//   Location location = Location();

//   LocationData? destinationLocation;

//   StreamSubscription<LocationData>? locationSubscription;

//     void initializeLocation(LocationData currentLocation, LocationData sourceLocation, String groupId, User user) async {
//     try {
//       currentLocation = await location.getLocation();
//       sourceLocation = currentLocation;
//       log(
//         "Current Location: ${currentLocation!.latitude}, ${currentLocation!.longitude}",
//       );
//       destinationLocation = LocationData.fromMap({
//         "latitude": 26.9943, //currentLocation?.latitude, //
//         "longitude": 31.4168, //currentLocation?.longitude, //
//       });

//       locationSubscription = location.onLocationChanged.listen((newLoc) {
//         currentLocation = newLoc;
//         updateLiveLocatio(
//           groupId,
//           user,
//           true,
//           currentLocation,
//           sourceLocation,
//         );
//         log(
//           "Updated Location: ${currentLocation!.latitude}, ${currentLocation!.longitude}",
//         );

//         //updatePolyline();

//         if (isMapReady && mapController != null) {
//           try {
//             mapController!.animateCamera(
//               CameraUpdate.newCameraPosition(
//                 CameraPosition(
//                   zoom: 13.5,
//                   target: LatLng(newLoc.latitude!, newLoc.longitude!),
//                 ),
//               ),
//             );
//           } catch (e) {
//             print("Error animating camera: $e");
//           }
//         }

//         setState(() {});
//       });
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   void updateLiveLocatio(
//     String id,
//     firebase_auth.User? user,
//     bool isEnabled,
//     LocationData? currentLocation, [
//     LocationData? sourceLocation,
//   ]) {
//     if (isEnabled && user != null && currentLocation != null) {
//       try {
//         log("update live location in fire store");
//         FirebaseFirestore.instance
//             .collection('groups')
//             .doc(id)
//             .collection('live_locations')
//             .doc(user!.uid)
//             .set({
//               'curLat': currentLocation!.latitude,
//               'curLng': currentLocation!.longitude,
//               'sourceLat': sourceLocation!.latitude,
//               'sourceLng': sourceLocation.longitude,
//               'timestamp': FieldValue.serverTimestamp(),
//             });
//       } catch (e) {
//         log("Error getting updating live location in firestore: $e");
//       }
//     } else {
//       log("delete live from fire store");
//       try {
//         if ('live_locations' != null) {
//           log("live_locations collection exist");
//           FirebaseFirestore.instance
//               .collection('groups')
//               .doc(id)
//               .collection('live_locations')
//               .doc(user!.uid)
//               .delete();
//         }
//       } catch (e) {
//         log("Error deleting live location: $e");
//       }
//     }
//   }

Future<bool?> checkIfGroupHasLiveLocations(String groupId) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('live_locations')
            .get();

    if (snapshot.docs.isEmpty) {
      log('📡 No live locations found for this group.');
      return false;
      
    } else {
      log('📍 Live locations exist!');
      return true;
     
    }
  } catch (e) {
    log('🔥 Error checking live locations from firestore: $e');
  }
}
