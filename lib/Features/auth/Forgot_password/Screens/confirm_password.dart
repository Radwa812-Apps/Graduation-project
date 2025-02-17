import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/auth/Forgot_password/Screens/change_password.dart';
import '../../../../core/constants.dart';
import '../components/circle_indicator.dart';
import '../components/custom_text_field.dart';
import '../components/forgot_password_button.dart';

class ConfirmPassword extends StatelessWidget {
  ConfirmPassword({super.key});
  static const confirmPasswordKey = '/ConfirmPassword';
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 393,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 85, left: 40),
                    child: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: kPrimaryColor1,
                    ),
                  ),
                ),

                const SizedBox(height: 200),
                // Circle Indicators Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleIndicator(
                      child: CustomTextField(
                        controller: _controllers[0],
                        currentFocus: _focusNodes[0],
                        nextFocus: _focusNodes[1],
                      ),
                    ),
                    CircleIndicator(
                      child: CustomTextField(
                        controller: _controllers[1],
                        currentFocus: _focusNodes[1],
                        nextFocus: _focusNodes[2],
                      ),
                    ),
                    CircleIndicator(
                      child: CustomTextField(
                        controller: _controllers[2],
                        currentFocus: _focusNodes[2],
                        nextFocus: _focusNodes[3],
                      ),
                    ),
                    CircleIndicator(
                      child: CustomTextField(
                        controller: _controllers[3],
                        currentFocus: _focusNodes[3],
                        nextFocus: null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Confirm Button
                ForgotPasswordButton(
                    buttonText: 'Confirm',
                    onTap: () {
                      Navigator.pushNamed(
                          context, ChangePassword.changePasswordKey);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
