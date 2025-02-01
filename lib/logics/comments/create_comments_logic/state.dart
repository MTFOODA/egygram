class CreateCommentStates {}

class CreateCommentInitialStates extends CreateCommentStates {}

class CreateCommentLoadingStates extends CreateCommentStates {}

class CreateCommentSuccessStates extends CreateCommentStates {}

class CreateCommentErrorStates extends CreateCommentStates {
  final String errorMessage;
  CreateCommentErrorStates(this.errorMessage);
}
