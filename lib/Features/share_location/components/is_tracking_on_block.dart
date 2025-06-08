// shared_value_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingOnCubit extends Cubit<bool> {
  TrackingOnCubit() : super(false);

  void updateValue(bool is_trackingOn) {
    emit(is_trackingOn);
  }
}
