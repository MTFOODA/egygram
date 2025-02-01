class CreateStoryStates {}

class CreateStoryInitialStates extends CreateStoryStates {}

class CreateStoryLoadingStates extends CreateStoryStates {}

class CreateStorySuccessStates extends CreateStoryStates {}

class CreateStoryErrorStates extends CreateStoryStates {
  final String errorMessage;
  CreateStoryErrorStates(this.errorMessage);
}
