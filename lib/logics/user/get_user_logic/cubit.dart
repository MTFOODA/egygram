import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetUserCubit extends Cubit<GetUsersState> {
  final UserRepository _userRepository;
  StreamSubscription<List<UsersModel>>? _subscription;

  GetUserCubit({UserRepository? userRepository})
      : _userRepository = userRepository ?? sl.userRepository,
        super(GetUserInitialState());

  /// Real-time stream of all users.
  Stream<List<UsersModel>> getUserStream() => _userRepository.watchUsers();

  /// Subscribe to real-time user updates. Safe to call multiple times.
  void getUsers() {
    emit(GetUserLoadingState());
    _subscription?.cancel();
    _subscription = getUserStream().listen(
      (users) => emit(GetUserSuccessState(users)),
      onError: (error) => emit(GetUserErrorState(friendlyError(error))),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
