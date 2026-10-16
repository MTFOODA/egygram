import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? sl.authRepository,
        super(LoginInitialState());

  Future login(String email, String password) async {
    emit(LoginLoadingState());
    try {
      await _authRepository.signIn(email: email, password: password);
      emit(LoginSuccessState());
    } catch (e) {
      emit(LoginErrorState(friendlyAuthError(e)));
    }
  }
}
