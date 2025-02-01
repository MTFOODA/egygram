import '../../../models/follow_model.dart';

abstract class GetFollowsState {}

class GetFollowInitialState extends GetFollowsState {}

class GetFollowLoadingState extends GetFollowsState {}

class GetFollowSuccessState extends GetFollowsState {
  final List<FollowsModel> follows;

  GetFollowSuccessState({required this.follows});
}

class GetFollowErrorState extends GetFollowsState {
  final String errorMessage;
  GetFollowErrorState(this.errorMessage);
}
