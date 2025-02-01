class CreatePostStates {}

class CreatePostInitialStates extends CreatePostStates {}

class CreatePostLoadingStates extends CreatePostStates {}

class CreatePostSuccessStates extends CreatePostStates {}

class CreatePostErrorStates extends CreatePostStates {
  final String errorMessage;
  CreatePostErrorStates(this.errorMessage);
}
