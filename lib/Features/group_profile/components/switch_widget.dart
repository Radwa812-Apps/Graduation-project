import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class SwitchWidget extends StatefulWidget {
  final bool initialFeatureStatus;
  final ValueChanged<bool>? onChanged; 

  const SwitchWidget({super.key, this.initialFeatureStatus = false, this.onChanged});

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  late bool _featureEnabled;

  @override
  void initState() {
    super.initState();
    _featureEnabled = widget.initialFeatureStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _featureEnabled,
      onChanged: (bool value) {
        setState(() {
          _featureEnabled = value;
        });
        if (widget.onChanged != null) widget.onChanged!(value); 
      },
      activeColor: kPrimaryColor1,
    );
  }
}