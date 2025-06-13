// shared_value_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingUserOnCubit extends Cubit<bool> {
  TrackingUserOnCubit() : super(false);

  void updateValue(bool is_userTrackingOn) {
    emit(is_userTrackingOn);
  }
}
