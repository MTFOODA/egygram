import '../../../models/Story_model.dart';

abstract class GetStoriesState {}

class GetStoryInitialState extends GetStoriesState {}

class GetStoryLoadingState extends GetStoriesState {}

class GetStorySuccessState extends GetStoriesState {
  final List<StoriesModel> stories;
  GetStorySuccessState(this.stories);
}

class GetStoryErrorState extends GetStoriesState {
  final String errorMessage;
  GetStoryErrorState(this.errorMessage);
}
