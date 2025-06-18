import 'package:flutter_bloc/flutter_bloc.dart';

/// Events
abstract class AlertEvent {}

class ActivateAlert extends AlertEvent {}
class DeactivateAlert extends AlertEvent {}

/// States
class AlertState {
  final bool isAlertpressed;
  AlertState(this.isAlertpressed);
}

/// Bloc
class AlertBloc extends Bloc<AlertEvent, AlertState> {
  AlertBloc() : super(AlertState(false)) {
    on<ActivateAlert>((event, emit) {
      emit(AlertState(true));
    });

    on<DeactivateAlert>((event, emit) {
      emit(AlertState(false));
    });
  }
}
