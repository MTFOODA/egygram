import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class EditPostCubit extends Cubit<EditPostsState> {
  final PostRepository _postRepository;

  EditPostCubit({PostRepository? postRepository})
      : _postRepository = postRepository ?? sl.postRepository,
        super(EditPostInitialState());

  Future<void> editPost(String postID, PostsModel updatedPost) async {
    emit(EditPostLoadingState());
    try {
      final existing = await _postRepository.getPost(postID);
      if (existing == null) {
        emit(EditPostErrorState("Post not found"));
        return;
      }
      await _postRepository.updatePost(postID, updatedPost);
      emit(EditPostSuccessState(updatedPost));
    } catch (e) {
      emit(EditPostErrorState(friendlyError(e)));
    }
  }
}
