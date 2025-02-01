import '../../../models/user_model.dart';

abstract class GetUsersState {}

class GetUserInitialState extends GetUsersState {}

class GetUserLoadingState extends GetUsersState {}

class GetUserSuccessState extends GetUsersState {
  final List<UsersModel> users;
  GetUserSuccessState(this.users);
}

class GetUserErrorState extends GetUsersState {
  final String errorMessage;
  GetUserErrorState(this.errorMessage);
}
