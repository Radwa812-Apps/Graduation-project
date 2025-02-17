import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/auth/Forgot_password/Screens/change_password2.dart';

import '../../../../core/Icons/arrow_back.dart';
import '../../../../core/constants.dart';
import '../components/change_password_textfield.dart';
import '../components/forgot_password_button.dart';
import '../components/password_field.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});
  static const changePasswordKey = '/ChangePassword';
  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          child: Stack(
            children: <Widget>[
              const ArrowBack(top: 85, left: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 300),
                        ChangePasswordTextfield(
                          textHint: 'New Password',
                          leftIcon: const Icon(Icons.lock_outlined,
                              color: kPrimaryColor1, size: 20),
                          rightIcon: PasswordField(
                            onVisibilityChanged: (isVisible) {
                              setState(() {
                                _isNewPasswordVisible = isVisible;
                              });
                            },
                          ),
                          controller: _newPasswordController,
                          isPasswordVisible: _isNewPasswordVisible,
                        ),
                        const SizedBox(height: 32),
                        ChangePasswordTextfield(
                          textHint: 'Confirm Password',
                          leftIcon: const Icon(Icons.check,
                              color: kPrimaryColor1, size: 20),
                          rightIcon: PasswordField(
                            onVisibilityChanged: (isVisible) {
                              setState(() {
                                _isConfirmPasswordVisible = isVisible;
                              });
                            },
                          ),
                          controller: _confirmPasswordController,
                          isPasswordVisible: _isConfirmPasswordVisible,
                        ),
                        const SizedBox(height: 78),
                        ForgotPasswordButton(
                          buttonText: 'Save',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pushNamed(context, ChangePassword2.changePassword2Key);
                            } else {
                              print('Please enter valid passwords.');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
