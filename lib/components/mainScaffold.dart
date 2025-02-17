import 'package:flutter/material.dart';
import 'package:near_me_new_version/Features/Notifications/Screens/general_notifications.dart';
import 'package:near_me_new_version/Features/Settings/screens/settings_screen.dart';
import 'package:near_me_new_version/components/bottom_bar.dart';
import '../Features/Home/Home/Screens/home_screen.dart';
import '../Features/User_Profile/screens/user_profile_screen.dart';

// Create a RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MainScaffold extends StatefulWidget {
  @override
  MainScaffoldState createState() => MainScaffoldState();
  static String mainScaffoldKey = '/MainScaffold';
}

class MainScaffoldState extends State<MainScaffold> with RouteAware {
  int _selectedIndex = 0;
  bool _showBottomBar = true;

  final List<Widget> _pages = [
    HomeScreen(),
    UserProfileScreen(),
    const GeneralNotifications(title: 'Notifications'),
    SettingsScreen(),
  ];
  
  // MainScaffoldState.add(super.ObjectFlagProperty) : super.add();

  void _onIconPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _updateBottomBarVisibility();
  }

  @override
  void didPopNext() {
    _updateBottomBarVisibility();
  }

  void _updateBottomBarVisibility() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    setState(() {
      _showBottomBar = currentRoute == MainScaffold.mainScaffoldKey ||
          currentRoute == HomeScreen.homeScreenKey ||
          currentRoute == UserProfileScreen.userProfileScreenKey ||
          currentRoute == GeneralNotifications.generalNotificationsKey ||
          currentRoute == SettingsScreen.settingsScreenKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _showBottomBar
          ? BottomContainerWithIcons(
              selectedIndex: _selectedIndex,
              onIconPressed: _onIconPressed,
            )
          : null,
    );
  }
}
