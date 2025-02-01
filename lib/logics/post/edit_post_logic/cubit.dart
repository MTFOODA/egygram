import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/post_model.dart';
import 'state.dart';

class EditPostCubit extends Cubit<EditPostsState> {
  EditPostCubit() : super(EditPostInitialState());

  // Edit Posts
  Future<void> editPost(String postID, PostsModel updatedPost) async {
    emit(EditPostLoadingState());

    try {
      final postDoc = await FirebaseFirestore.instance
          .collection("Posts")
          .doc(postID)
          .get();

      if (!postDoc.exists) {
        emit(EditPostErrorState("Post not found"));
        return;
      }

      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(postID)
          .update(updatedPost.toMap());

      emit(EditPostSuccessState(updatedPost));
    } catch (e) {
      emit(EditPostErrorState(e.toString()));
    }
  }
}
