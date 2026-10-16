import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreateUserCubit extends Cubit<CreateUserStates> {
  final UserRepository _userRepository;

  CreateUserCubit({UserRepository? userRepository})
      : _userRepository = userRepository ?? sl.userRepository,
        super(CreateUserInitialStates());

  Future createUser(UsersModel users) async {
    emit(CreateUserLoadingStates());
    try {
      await _userRepository.createUser(users);
      emit(CreateUserSuccessStates());
    } catch (e) {
      emit(CreateUserErrorStates(friendlyError(e)));
    }
  }
}
