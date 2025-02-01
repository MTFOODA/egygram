class CreateSaveStates {}

class CreateSaveInitialStates extends CreateSaveStates {}

class CreateSaveLoadingStates extends CreateSaveStates {}

class CreateSaveSuccessStates extends CreateSaveStates {}

class CreateSaveErrorStates extends CreateSaveStates {
  final String errorMessage;
  CreateSaveErrorStates(this.errorMessage);
}
