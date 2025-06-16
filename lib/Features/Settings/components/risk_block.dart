// shared_value_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class RiskCubit extends Cubit<bool> {
  RiskCubit() : super(false);

  void updateValue(bool is_RiskOn) {
    emit(is_RiskOn);
  }
}
