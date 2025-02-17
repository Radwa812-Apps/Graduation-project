import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<bool> checkConnection() async {
  

  bool result = await InternetConnection().hasInternetAccess;
  final listener =
      InternetConnection().onStatusChange.listen((InternetStatus status) {
    switch (status) {
      case InternetStatus.connected:
        print('connected');
        result = true;
        break;
      case InternetStatus.disconnected:
        print('disconnected');
        result = false;
        break;
    }
  });

  return result;
}