import '../../../models/user_model.dart';

abstract class EditUsersState {}

class EditUserInitialState extends EditUsersState {}

class EditUserLoadingState extends EditUsersState {}

class EditUserSuccessState extends EditUsersState {
  final UsersModel updatedUser;
  EditUserSuccessState(this.updatedUser);
}

class EditUserErrorState extends EditUsersState {
  final String errorMessage;
  EditUserErrorState(this.errorMessage);
}
