import 'package:flutter_application_3/models/post_model.dart';

abstract class GetPostsState {}

class GetPostInitialState extends GetPostsState {}

class GetPostLoadingState extends GetPostsState {}

class GetPostSuccessState extends GetPostsState {
  final List<PostsModel> posts;
  GetPostSuccessState(this.posts);
}

class GetPostErrorState extends GetPostsState {
  final String errorMessage;
  GetPostErrorState(this.errorMessage);
}
