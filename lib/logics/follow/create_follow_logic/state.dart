class CreateFollowStates {}

class CreateFollowInitialStates extends CreateFollowStates {}

class CreateFollowLoadingStates extends CreateFollowStates {}

class CreateFollowSuccessStates extends CreateFollowStates {}

class CreateFollowErrorStates extends CreateFollowStates {
  final String errorMessage;
  CreateFollowErrorStates(this.errorMessage);
}
