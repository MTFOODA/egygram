import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/comment_model.dart';
import 'state.dart';

class CreateCommentCubit extends Cubit<CreateCommentStates> {
  CreateCommentCubit() : super(CreateCommentInitialStates());

  // create Comment
  Future createComment(CommentsModel comments) async {
    emit(CreateCommentLoadingStates());
    try {
      await FirebaseFirestore.instance
          .collection("Comments")
          .add(comments.toMap());
      emit(CreateCommentSuccessStates());
    } catch (e) {
      emit(CreateCommentErrorStates(e.toString()));
    }
  }
}
