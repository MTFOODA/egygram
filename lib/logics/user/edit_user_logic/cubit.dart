import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class EditUserCubit extends Cubit<EditUsersState> {
  final UserRepository _userRepository;

  EditUserCubit({UserRepository? userRepository})
      : _userRepository = userRepository ?? sl.userRepository,
        super(EditUserInitialState());

  Future<void> editUser(String userName, UsersModel updatedUser) async {
    emit(EditUserLoadingState());
    try {
      await _userRepository.updateUser(userName, updatedUser);
      emit(EditUserSuccessState(updatedUser));
    } catch (e) {
      emit(EditUserErrorState(friendlyError(e)));
    }
  }
}
