class CreateUserStates {}

class CreateUserInitialStates extends CreateUserStates {}

class CreateUserLoadingStates extends CreateUserStates {}

class CreateUserSuccessStates extends CreateUserStates {}

class CreateUserErrorStates extends CreateUserStates {
  final String errorMessage;
  CreateUserErrorStates(this.errorMessage);
}
