class CreateLoveStates {}

class CreateLoveInitialStates extends CreateLoveStates {}

class CreateLoveLoadingStates extends CreateLoveStates {}

class CreateLoveSuccessStates extends CreateLoveStates {}

class CreateLoveErrorStates extends CreateLoveStates {
  final String errorMessage;
  CreateLoveErrorStates(this.errorMessage);
}
