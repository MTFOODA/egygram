import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthRepository _authRepository;

  LogoutCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? sl.authRepository,
        super(LogoutInitialState());

  Future logout() async {
    emit(LogoutLoadingState());
    try {
      await _authRepository.signOut();
      emit(LogoutSuccessState());
    } catch (e) {
      emit(LogoutErrorState(friendlyError(e)));
    }
  }
}
