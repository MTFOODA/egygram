import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/models/post_model.dart';
import 'state.dart';

class CreatePostCubit extends Cubit<CreatePostStates> {
  CreatePostCubit() : super(CreatePostInitialStates());

  // create Post
  Future<void> createPost(PostsModel posts) async {
    emit(CreatePostLoadingStates());
    try {
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(posts.postID)
          .set(posts.toMap());
      emit(CreatePostSuccessStates());
    } catch (e) {
      emit(CreatePostErrorStates(e.toString()));
    }
  }
}
