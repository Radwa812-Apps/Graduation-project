import 'package:flutter/material.dart';
import '../../../../core/Icons/arrow_back.dart';
import '../../../../core/constants.dart' show background, kPrimaryColor1;
import '../components/change_password_textfield.dart';
import '../components/forgot_password_button.dart';
import '../components/password_field.dart';
class ChangePassword2 extends StatefulWidget {
  const ChangePassword2({super.key});
  static const changePassword2Key = '/ChangePassword2';

  @override
  State<ChangePassword2> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword2> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:background,
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
                          textHint: 'Old Password',
                          leftIcon: Icon(Icons.lock_outlined, color: kPrimaryColor1, size: 20),
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
                          textHint: 'New Password',
                          leftIcon: Icon(Icons.check, color: kPrimaryColor1, size: 20),
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
                              print('Passwords are valid!');
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
