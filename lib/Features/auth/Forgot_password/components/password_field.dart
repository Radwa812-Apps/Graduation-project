import 'package:flutter/material.dart';

import '../../../../core/constants.dart';

class PasswordField extends StatefulWidget {
  final Function(bool) onVisibilityChanged;

  const PasswordField({
    Key? key,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  _PasswordVisibilityToggleState createState() => _PasswordVisibilityToggleState();
}

class _PasswordVisibilityToggleState extends State<PasswordField> {
  bool _isPasswordVisible = false;

  void _toggleVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
      widget.onVisibilityChanged(_isPasswordVisible);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: kPrimaryColor1,
        size: 20,
      ),
      onPressed: _toggleVisibility,
    );
  }
}
