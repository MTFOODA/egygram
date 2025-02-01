import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/logics/auth/logout_logic/state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitialState());

  // Logout function
  Future logout() async {
    emit(LogoutLoadingState());
    try {
      await FirebaseAuth.instance.signOut();
      emit(LogoutSuccessState());
    } catch (e) {
      emit(LogoutErrorState(e.toString()));
    }
  }
}
