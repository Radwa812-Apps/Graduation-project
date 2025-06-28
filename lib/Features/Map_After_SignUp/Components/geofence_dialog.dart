import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GeofenceEditDialog extends StatelessWidget {
  final String placeName;
  final TextEditingController controller;
  final double radius;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onSave;

  const GeofenceEditDialog({
    required this.placeName,
    required this.controller,
    required this.radius,
    required this.onRadiusChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Geofence',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Location Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.place),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Geofence Radius: ${radius.round()} meters',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: radius,
            min: 50,
            max: 1000,
            divisions: 19,
            label: radius.round().toString(),
            onChanged: onRadiusChanged,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onSave,
              child: Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}