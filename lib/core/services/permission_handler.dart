import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  Future<bool> _checkPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    if (status.isDenied) {
      status = await permission.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      status = await permission.status;
      return status.isGranted;
    } else {
      return status.isGranted;
    }
  }
Future<PermissionStatus> getStatus(Permission permission) async {
  return await permission.status;
}

  Future<bool> checkLocationPermission() async =>
      await _checkPermission(Permission.location);

  Future<bool> checkCameraPermission() async =>
      await _checkPermission(Permission.camera);
  Future<bool> checkContactPermission() async =>
      await _checkPermission(Permission.contacts);
  Future<bool> checkMicrophonePermission() async =>
      await _checkPermission(Permission.microphone);
  Future<bool> checkNotificationPermission() async =>
      await _checkPermission(Permission.notification);
  Future<bool> checkStoragePermission() async =>
      await _checkPermission(Permission.storage);

  Future<bool> _denyPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    if (status.isGranted) {
      status = await permission.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      status = await permission.status;
      return status.isGranted;
    } else {
      return status.isGranted;
    }
  }

  Future<bool> locationPermission() async =>
      await _denyPermission(Permission.location);

  Future<bool> cameraPermission() async =>
      await _denyPermission(Permission.camera);
  Future<bool> contactPermission() async =>
      await _denyPermission(Permission.contacts);
  Future<bool> microphonePermission() async =>
      await _denyPermission(Permission.microphone);
  Future<bool> notificationPermission() async =>
      await _checkPermission(Permission.notification);
  Future<bool> storagePermission() async =>
      await _denyPermission(Permission.storage);
}
