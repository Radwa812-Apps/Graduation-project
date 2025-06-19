import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/general_notifications.dart';
import 'package:near_me_new_version/Features/Settings/components/risk_block.dart';
import 'package:near_me_new_version/Features/Settings/screens/settings_screen.dart';
import 'package:near_me_new_version/Features/Splash_page/Screens/after_splash.dart';
import 'package:near_me_new_version/Features/Splash_page/Screens/splash_screen.dart';
import 'package:near_me_new_version/Features/User_Profile/screens/user_profile_screen.dart';
import 'package:near_me_new_version/Features/auth/Forgot_password/Screens/change_password.dart';
import 'package:near_me_new_version/Features/auth/Forgot_password/Screens/change_password2.dart';
import 'package:near_me_new_version/Features/auth/Forgot_password/Screens/confirm_password.dart';
import 'package:near_me_new_version/Features/auth/Forgot_password/Screens/forgot_password.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/add_user_success.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/signUp_verifiy_email.dart';
import 'package:near_me_new_version/Features/auth/Sign_up_and_in/screens/sign_up_screen.dart';
import 'package:near_me_new_version/Features/chat_group/screens/group_chat.dart';
import 'package:near_me_new_version/Features/group_profile/screens/add_members_screen.dart';
import 'package:near_me_new_version/Features/group_profile/screens/search_member.dart';
import 'package:near_me_new_version/Features/select_place/screens/select_place_screen.dart';
import 'package:near_me_new_version/Features/share_location/components/is_tracking_on_block.dart';
import 'package:near_me_new_version/Features/share_location/screens/live_location_map.dart';
import 'package:near_me_new_version/Features/share_location/screens/test.dart';
import 'package:near_me_new_version/components/mainScaffold.dart';
import 'package:near_me_new_version/core/data/bloc/Auth/auth_bloc.dart';
import 'package:near_me_new_version/core/data/bloc/Risk/bloc_singletons.dart';
import 'package:near_me_new_version/core/data/bloc/custom_places/custom_places_bloc.dart';
import 'package:near_me_new_version/core/data/bloc/profile/profile_bloc.dart';
import 'package:near_me_new_version/core/data/bloc/Risk/risk_bloc.dart';
import 'package:near_me_new_version/core/data/models/chat_model_temp.dart';
import 'package:near_me_new_version/core/services/Auth_functions.dart';
import 'package:near_me_new_version/core/services/chat_services.dart'
    show ChatService;
import 'package:near_me_new_version/core/services/cloudinary_service.dart';
import 'package:near_me_new_version/core/services/risk_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Features/Home/Home/Screens/home_screen.dart';
import 'Features/Map_After_SignUp/Screens/map1.dart';
import 'Features/Notifications/Screens/group_notifications.dart';
import 'Features/Notifications/Screens/personal_notifications.dart';
import 'Features/Permissions/Screens/permission_location.dart';
import 'Features/Permissions/Screens/permissions.dart';
import 'Features/Private_chat/screens/private_chat_screen.dart';
import 'Features/User_Profile/screens/edit_screen.dart';
import 'Features/auth/Forgot_password/Screens/send_email_for_pass.dart';
import 'Features/auth/Sign_up_and_in/screens/sign_in_screen.dart';
import 'Features/group_profile/screens/group_inside.dart';
import 'Features/group_profile/screens/group_profile_screen.dart';
import 'Features/group_profile/screens/media.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel(
  'com.example.near_me_new_version/floating_button',
);
RiskServices _riskServices = RiskServices();
// Use only one import path

void main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /*runApp(
    ScreenUtilInit(
      builder: (BuildContext context, Widget? child) {
        return NearMeApp();
      },
      child: ChangeNotifierProvider(create: (_) => ChatModelTemp()),
    ),
  );*/
  const encryptionKey = 'your-256-bit-super-secret-key!!';

  runApp(
    ScreenUtilInit(
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ChatModelTemp()),

            Provider<CloudinaryService>(
              create:
                  (_) => CloudinaryService(
                    auth: FirebaseAuth.instance,
                    encryptionKey: encryptionKey,
                  ),
            ),

            Provider<ChatService>(
              create:
                  (context) => ChatService(
                    cloudinary: context.read<CloudinaryService>(),
                    encryptionKey: encryptionKey,
                  ),
            ),
            ChangeNotifierProvider(create: (_) => ChatModelTemp()),
            Provider<ChatService>(
              create: (_) => ChatService(encryptionKey: encryptionKey),
            ),
            BlocProvider(create: (context) => AuthBloc(Services())),
            BlocProvider(create: (context) => CustomPlacesBloc(Services())),
            BlocProvider(create: (context) => ProfileBloc()),
            BlocProvider(create: (context) => TrackingUserOnCubit()),
            BlocProvider(create: (context) => RiskCubit()),
            BlocProvider.value(value: alertBloc, child: NearMeApp()),
          ],
          child: NearMeApp(),
        );
      },
      child: Container(), // Empty container since providers are now above
    ),
  );
  platform.setMethodCallHandler((call) async {
    if (call.method == 'onFloatingButtonPressed') {
       print('Floating button pressed from Android!');
      _riskServices.handleRiskbutton();
    }
  });
}

// ignore: must_be_immutable
class NearMeApp extends StatefulWidget {
  NearMeApp({super.key});

  @override
  State<NearMeApp> createState() => _NearMeAppState();
}

class _NearMeAppState extends State<NearMeApp> {
  bool isUserLoggedIn = false;
  @override
  void initState() {
    log("main init");
    _handleRiskSwitch();
  }

  void _handleRiskSwitch() async {
    bool isAlertActive = await _riskServices.checkRiskSwitch() ?? false;
    _riskServices.toggleFloatingButton(isAlertActive);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else {
          isUserLoggedIn = snapshot.data?.getBool('KeppUserLogIn') ?? false;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => AuthBloc(Services()),
                child: Container(),
              ),
              BlocProvider(
                create: (context) => CustomPlacesBloc(Services()),
                child: Container(),
              ),
              BlocProvider(
                create: (context) => ProfileBloc(),
                child: UserProfileScreen(),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorObservers: [routeObserver],
              initialRoute: SplashPage.splashPageKey,
              routes: {
                '/': (context) => HomeScreen(),
                SplashPage.splashPageKey: (context) => const SplashPage(),
                //'/shimass': (context) => const Map1shimaa(),
                SignUpScreen.signUpScreenKey: (context) => const SignUpScreen(),
                SignInScreen.signInScreenKey: (context) => SignInScreen(),
                ChangePassword.changePasswordKey:
                    (context) => const ChangePassword(),
                Permissions.permissionsKey: (context) => const Permissions(),
                PermissionLocation.permissionLocationKey:
                    (context) => PermissionLocation(),
                ConfirmPassword.confirmPasswordKey:
                    (context) => ConfirmPassword(),
                ChangePassword2.changePassword2Key:
                    (context) => const ChangePassword2(),
                ForgotPassword.forgotPasswordKey: (context) => ForgotPassword(),
                WelcomeView.welcomeViewKey: (context) => WelcomeView(),
                HomeScreen.homeScreenKey: (context) => HomeScreen(),
                Map1.map1Key: (context) => const Map1(),
                GeneralNotifications.generalNotificationsKey:
                    (context) => const GeneralNotifications(title: 'Radwa'),
                // SplashPage.splashPageKey: ((context) => const SplashPage()),
                SuccessPage.successPageKey: ((context) => SuccessPage()),
                SignUpVerificationEmailPage.signUpVerificationEmailPageKey:
                    (context) =>
                        SignUpVerificationEmailPage(services: Services()),
                MainScaffold.mainScaffoldKey: (context) => MainScaffold(),
                SettingsScreen.settingsScreenKey: (context) => SettingsScreen(),
                GroupProfileScreen.groupProfileScreenKey:
                    (context) => GroupProfileScreen(),
                AddMembersScreen.addMembersScreenKey:
                    (context) => AddMembersScreen(),
                GroupChat.groupChatKey: (context) {
                  final args =
                      ModalRoute.of(context)!.settings.arguments
                          as Map<String, String>;
                  return GroupChat(
                    groupId: args['groupId']!,
                    groupName: args['groupName']!,
                  );
                },
                EditScreen.editScreenKey: (context) => EditScreen(),
                GroupNotifications.groupNotificationsKey:
                    (context) => const GroupNotifications(title: 'Alex Trip'),
                PersonalNotifications.personalNotificationsKey:
                    (context) => PermissionLocation(),
                PrivateChatScreen.privateChatScreenKey:
                    (context) => const PrivateChatScreen(recipient: 'Radwa'),
                SearchMember.searchMemberKey: (context) => const SearchMember(),
                SelectPlaceScreen.selectPlaceScreenKey:
                    ((context) => const SelectPlaceScreen()),
                MediaScreen.mediaScreenKey: (context) => const MediaScreen(),
                PasswordResetPage.passwordResetPageKey:
                    (context) => const PasswordResetPage(),
                GroupInsideScreen.groupInsideScreenKey:
                    (context) => GroupInsideScreen(),
                OrderTrackingPage.orderTrackingScreenKey:
                    (context) => OrderTrackingPage(),
                CustomMarkerMap.customMarkerMapScreenKey:
                    (context) => CustomMarkerMap(),
              },
            ),
          );
        }
      }),
    );
  }
}
