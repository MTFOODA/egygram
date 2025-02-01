import 'package:flutter_application_3/models/comment_model.dart';

abstract class GetCommentsState {}

class GetCommentInitialState extends GetCommentsState {}

class GetCommentLoadingState extends GetCommentsState {}

class GetCommentSuccessState extends GetCommentsState {
  final List<CommentsModel> comments;
  GetCommentSuccessState(this.comments);
}

class GetCommentErrorState extends GetCommentsState {
  final String errorMessage;
  GetCommentErrorState(this.errorMessage);
}
