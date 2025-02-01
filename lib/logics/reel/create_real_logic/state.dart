class CreateReelStates {}

class CreateReelInitialStates extends CreateReelStates {}

class CreateReelLoadingStates extends CreateReelStates {}

class CreateReelSuccessStates extends CreateReelStates {}

class CreateReelErrorStates extends CreateReelStates {
  final String errorMessage;
  CreateReelErrorStates(this.errorMessage);
}
