import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? sl.authRepository,
        super(SignupInitialState());

  Future signUp(String email, String password, String userName) async {
    emit(SignupLoadingState());
    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        userName: userName,
      );
      emit(SignupSuccessState());
    } catch (e) {
      emit(SignupErrorState(friendlyAuthError(e)));
    }
  }
}
