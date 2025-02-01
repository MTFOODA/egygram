import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/logics/post/get_post_logic/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/models/post_model.dart';

class GetPostCubit extends Cubit<GetPostsState> {
  GetPostCubit() : super(GetPostInitialState());

  Stream<List<PostsModel>> getPost() {
    return FirebaseFirestore.instance
        .collection("Posts")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostsModel.fromMap(doc.data()))
        .toList());
  }

  // Subscribe to snapshot changes
  void subscribeToPosts() {
    emit(GetPostLoadingState());

    getPost().listen(
          (posts) {
        emit(GetPostSuccessState(posts));
      },
      onError: (error) {
        emit(GetPostErrorState(error.toString()));
      },
    );
  }
}
