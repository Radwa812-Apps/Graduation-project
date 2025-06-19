import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart' as Location;
import 'package:near_me_new_version/Features/share_location/components/firebase_controller.dart';
import 'package:near_me_new_version/core/data/bloc/Risk/bloc_singletons.dart';
import 'package:near_me_new_version/core/data/bloc/Risk/risk_bloc.dart';
import 'package:near_me_new_version/core/data/models/location.dart';

class RiskServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseController _firebaseController = FirebaseController();
  Future<bool?> checkRiskSwitch() async {
    String? userId = _auth.currentUser?.uid;
    bool isAlertActive;
    try {
      final DocumentSnapshot riskPreferences =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('settings')
              .doc('risk_preferences')
              .get();

      if (!riskPreferences.exists) {
        isAlertActive = false;
        log("not found1");
      }

      final data = riskPreferences.data() as Map<String, dynamic>?;
      final dynamic riskSwitch = data?['risk_switch'];

      if (riskSwitch == true) {
        isAlertActive = true;
        log("isAlertactive2: $isAlertActive");
      } else if (riskSwitch == false) {
        isAlertActive = false;
        log("isAlertactive3: $isAlertActive");
      } else {
        isAlertActive = false;
        log("isAlertactive4: $isAlertActive");
      }
      return isAlertActive;
    } catch (e) {
      log('Error checking risk_switch: $e');
      return null;
    }
  }

  Future<List<String>?> _getSelectedRiskGroups(String? userId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('selected_alert_groups')
        .doc(userId);

    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      print('User not found in selected_alert_groups');
      return null;
    }

    final List<String> groupIds = List<String>.from(
      docSnapshot.data()?['groups'] ?? [],
    );

    if (groupIds.isEmpty) {
      print('No groups found for this user');
      return null;
    }
    return groupIds;
  }

  Future<void> toggleFloatingButton(bool value) async {
    try {
      final result = await MethodChannel(
        'com.example.near_me_new_version/floating_button',
      ).invokeMethod('toggleFloatingButton', {'enable': value});
      print(result);
    } catch (e) {
      print("Error toggling floating button: $e");
    }
  }

  void handleRiskbutton() async {
    User? user = _auth.currentUser;
    bool isAlertActive = false;
    final Location.Location _location = Location.Location();
    FirebaseController _firebaseController = FirebaseController();
    Location.LocationData currentLocation, sourceLocation;
    currentLocation = await _location.getLocation();
    sourceLocation = currentLocation;
    log("alert active $isAlertActive");
    isAlertActive = await checkRiskSwitch() ?? false;
    log("alert active $isAlertActive");
    log("Userid: $user");
    if (user == null) {
      return;
    }
    final List<String>? groupIds = await _getSelectedRiskGroups(user!.uid);
    if (isAlertActive && groupIds != null) {
      for (String groupId in groupIds) {
        _firebaseController.createLiveLocationInstance(
          groupId,
          user,
          currentLocation,
          sourceLocation,
        );
        log("live locaton for group: $groupId");
      }
    }
    alertBloc.add(ActivateAlert());
  }

  void resetToggleAlert() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return;
    }
    final List<String>? riskGroups = await _getSelectedRiskGroups(user.uid);
    if (riskGroups != null) {
      for (var groupId in riskGroups) {
        _firebaseController.stopAlertAnimation(groupId);
      }
    } else {
      log("no selected groups!!");
    }
  }
}
