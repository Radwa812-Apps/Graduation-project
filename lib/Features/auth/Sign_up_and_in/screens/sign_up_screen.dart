import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/components/phone_widget.dart';
import '../../../../core/data/bloc/Auth/auth_bloc.dart';
import '../../../../core/messages.dart';
import '../../../../core/services/validator.dart';
import '../components/bold_text_widget.dart';
import '../components/functions.dart';
import '../components/have_an_account_widget.dart';
import '../components/linear_gradient_widget.dart';
import '../components/submit_button.dart';
import '../components/text_form_widget.dart';
import 'signUp_verifiy_email.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const String signUpScreenKey = '/SignUpScreen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  double space = 30;
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isload = false;
  String? fName, lName, password, email, phoneNumber, dateOfBirth;
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneNumberController.clear();
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          Navigator.pushNamed(
            context,
            SignUpVerificationEmailPage.signUpVerificationEmailPageKey,
            arguments: {
              'email': email,
              'dateOfBirth': dateOfBirth,
              'phoneNumber': phoneNumber,
              'fname': fName,
              'lname': lName,
            },
          );
          isload = false;
        } else if (state is RegisterError) {
          isload = false;
          AppMessages().sendVerification(
            (context),
            Colors.red.withOpacity(0.8),
            state.registerError,
          );
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
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const Center(child: BoldTextWidget(name: 'Sign Up')),
                          SizedBox(height: 30.h),
                          TextFormFieldWidget(
                            hintColor: Colors.white,
                            lineColor: Colors.white,
                            controller: _fnameController,
                            hint: 'First Name',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                            keyboardType: TextInputType.text,
                            validatior:
                                ((p0) => Validator.validateEmptyField(
                                  'First Name',
                                  p0,
                                )),
                            onchange: ((p0) {
                              fName = p0;
                            }),
                            lineFocusColor: Colors.white,
                            editIcon: null,
                          ),
                          SizedBox(height: 20.h),
                          TextFormFieldWidget(
                            editIcon: null,
                            lineFocusColor: Colors.white,
                            hintColor: Colors.white,
                            lineColor: Colors.white,
                            controller: _lnameController,
                            hint: 'Last Name',
                            prefixIcon: const Icon(
                              Icons.people_outline,
                              color: Colors.white,
                            ),
                            keyboardType: TextInputType.text,
                            validatior:
                                ((p0) => Validator.validateEmptyField(
                                  'Last Name',
                                  p0,
                                )),
                            onchange: ((p0) {
                              lName = p0;
                            }),
                          ),
                          SizedBox(height: 20.h),
                          TextFormFieldWidget(
                            editIcon: null,
                            lineFocusColor: Colors.white,
                            hintColor: Colors.white,
                            lineColor: Colors.white,
                            controller: _emailController,
                            hint: 'Email',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.white,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validatior: ((p0) => Validator.validateEmail(p0)),
                            onchange: ((p0) {
                              email = p0;
                            }),
                          ),
                          SizedBox(height: 20.h),
                          PhoneNumberWidget(
                            textColor: Colors.white,
                            phoneNumberController: _phoneNumberController,
                            hint: 'Phone Number',
                            dropdownIconColor: Colors.white,
                            dropdownTextStyleColor: Colors.white,
                            enabledBorderColor: Colors.white,
                            focusedBorderColor: Colors.white,
                            hintStyleColor: Colors.white,
                            
                            onchange: ((p0) {
                              setState(() {
                                phoneNumber = p0.toString();
                              });
                            }),
                            widget: null,
                          ),

                          SizedBox(height: 5.h),
                          TextFormFieldWidget(
                            editIcon: null,
                            lineFocusColor: Colors.white,
                            validatior: ((p0) {
                              if (p0 == null || p0.isEmpty) {
                                return "Date of birth is required.";
                              }
                              final parts = p0.split('/');
                              if (parts.length == 3) {
                                final formattedDate =
                                    "${parts[2]}-${parts[1]}-${parts[0]}";
                                final date = DateTime.tryParse(formattedDate);
                                if (date == null) {
                                  return "Invalid date format.";
                                }
                                return Validator.validateDateOfBirth(date);
                              } else {
                                return "Invalid date format.";
                              }
                            }),
                            hint: 'BirthDate',
                            prefixIcon: const Icon(
                              Icons.edit_calendar_rounded,
                              color: Colors.white,
                            ),
                            isBirthDate: true,
                            controller: _dateController,
                            onTap: (() async {
                              await selectDate(context, _dateController, (
                                selectedDate,
                              ) {
                                dateOfBirth = selectedDate;
                              });
                            }),
                            onchange: ((p0) {}),
                            hintColor: Colors.white,
                            lineColor: Colors.white,
                          ),
                          SizedBox(height: 20.h),
                          TextFormFieldWidget(
                            editIcon: null,
                            lineFocusColor: Colors.white,
                            hintColor: Colors.white,
                            lineColor: Colors.white,
                            controller: _passwordController,
                            hint: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            validatior:
                                ((p0) => Validator.validatePassword(p0)),
                            onchange: ((p0) {
                              password = p0;
                            }),
                          ),
                          SizedBox(height: 20.h),
                          TextFormFieldWidget(
                            editIcon: null,
                            lineFocusColor: Colors.white,
                            hintColor: Colors.white,
                            lineColor: Colors.white,
                            controller: _confirmPasswordController,
                            hint: 'Confirm Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            validatior:
                                ((p0) => Validator.validateConfirmPassword(
                                  p0,
                                  _passwordController.text,
                                )),
                            onchange: ((p0) {}),
                          ),
                          SizedBox(height: 60.h),
                          SubmitButton(
                            name: 'Sign Up',
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                if (phoneNumber == null) {
                                  AppMessages().sendVerification(
                                    (context),
                                    Colors.red.withOpacity(0.8),
                                    'phone Number is required',
                                  );
                                } else {
                                  BlocProvider.of<AuthBloc>(
                                    context,
                                  ).add(RegisterEvent(email!, password!));
                                }
                              }
                            },
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(height: 5.h),
                          HaveAnAccountWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
