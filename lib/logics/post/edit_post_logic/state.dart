import '../../../models/post_model.dart';

abstract class EditPostsState {}

class EditPostInitialState extends EditPostsState {}

class EditPostLoadingState extends EditPostsState {}

class EditPostSuccessState extends EditPostsState {
  final PostsModel updatedPost;
  EditPostSuccessState(this.updatedPost);
}

class EditPostErrorState extends EditPostsState {
  final String errorMessage;
  EditPostErrorState(this.errorMessage);
}
