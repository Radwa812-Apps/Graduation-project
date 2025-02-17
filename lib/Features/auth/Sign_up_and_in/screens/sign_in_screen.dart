import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:near_me_new_version/Features/Permissions/Screens/permissions.dart';
import 'package:near_me_new_version/Features/auth/Forgot_password/Screens/forgot_password.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_up_screen.dart';
import 'package:near_me_new_version/core/data/bloc/Auth/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants.dart';
import '../../../../core/services/signInWithGoogle.dart';
import '../../../../core/messages.dart';
import '../components/bold_text_widget.dart';
import '../components/linear_gradient_widget.dart';
import '../components/or_widget.dart';
import '../components/submit_button.dart';
import '../components/text_form_widget.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
  static const String signInScreenKey = '/SignInScreen';
}

class _SignInScreenState extends State<SignInScreen> {
  double space = 30;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? email, password;
  bool isload = false;
  bool? rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.pushNamed(context, Permissions.permissionsKey);
        } else if (state is LoginError) {
          isload = false;
          AppMessages().sendVerification(
              (context), Colors.red.withOpacity(0.8), state.loginError);
        } else {
          isload = true;
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isload,
          child: Scaffold(
            body: Stack(
              children: [
                NearMeGradientColor(),
                Form(
                  key: formKey,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: 20.h),
                      const Center(
                        child: BoldTextWidget(
                          name: 'Sign In',
                        ),
                      ),
                      SizedBox(height: 100.h),
                      TextFormFieldWidget(
                        lineFocusColor: Colors.white,
                        hintColor: Colors.white,
                        lineColor: Colors.white,
                        controller: _emailController,
                        hint: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validatior: ((p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "Email is required.";
                          }
                          return null;
                        }),
                        onchange: ((p0) {
                          email = p0;
                        }), editIcon: null,
                      ),
                      SizedBox(height: 30.h),
                      TextFormFieldWidget(
                        lineFocusColor: Colors.white,
                        hintColor: Colors.white,
                        lineColor: Colors.white,
                        controller: _passwordController,
                        hint: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.white),
                        keyboardType: TextInputType.text,
                        isPassword: true,
                        validatior: ((p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "PassWord is required.";
                          }
                          return null;
                        }),
                        onchange: ((p0) {
                          password = p0;
                        }), editIcon: null,
                      ),
                      SizedBox(height: 10.h),
                      
                      Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value;
                                });
                                keppUserLogIn(value ?? false);
                              },
                              activeColor: kSpecialColor,
                              checkColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white,
                                width: 2.w,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // SizedBox(width: 1.w),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: kFontBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 200.w),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, ForgotPassword.forgotPasswordKey);
                          },
                          child: Text(
                            "Forget Password?",
                            style: TextStyle(
                              color: kSpecialColor,
                              fontSize: 17.sp,
                              fontFamily: kFontBold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      SubmitButton(
                        name: 'Sign In',
                        onTap: () {
                          if (rememberMe == true) {
                            keppUserLogIn(rememberMe!);
                          }

                          if (formKey.currentState!.validate()) {
                            BlocProvider.of<AuthBloc>(context)
                                .add(LoginEvent(email!, password!));
                          } else {}
                        },
                      ),
                      SizedBox(height: 10.h),
                      ORWediget(
                        oRsize: 13.sp,
                        lineWidth: 80.w,
                      ),
                      SizedBox(height: 10.h),
                      SocialAuthWidget(),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontFamily: kFontBold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, SignUpScreen.signUpScreenKey);
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: kSpecialColor,
                                fontSize: 18.sp,
                                fontFamily: kFontBold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void keppUserLogIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('KeppUserLogIn', value);
  }
}
