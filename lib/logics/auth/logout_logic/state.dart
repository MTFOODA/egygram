abstract class LogoutState {}

class LogoutInitialState extends LogoutState {}

class LogoutLoadingState extends LogoutState {}

class LogoutSuccessState extends LogoutState {}

class LogoutErrorState extends LogoutState {
  final String message;
  LogoutErrorState(this.message);
}
