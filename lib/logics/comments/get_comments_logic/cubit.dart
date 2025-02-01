import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/comment_model.dart';
import 'state.dart';

class GetCommentCubit extends Cubit<GetCommentsState> {
  GetCommentCubit() : super(GetCommentInitialState());

  void getComments(String postId) {
    emit(GetCommentLoadingState());

    FirebaseFirestore.instance
        .collection('Comments')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .listen((snapshot) {
      final comments = snapshot.docs.map((doc) {
        return CommentsModel.fromMap(doc.data());
      }).toList();

      emit(GetCommentSuccessState(comments));
    }, onError: (error) {
      emit(GetCommentErrorState(error.toString()));
    });
  }
}
