class SignUpState {}

class SignupInitialState extends SignUpState {}

class SignupLoadingState extends SignUpState {}

class SignupSuccessState extends SignUpState {}

class SignupErrorState extends SignUpState {
  final String error;
  SignupErrorState(this.error);
}
