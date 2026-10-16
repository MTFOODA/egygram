import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreatePostCubit extends Cubit<CreatePostStates> {
  final PostRepository _postRepository;

  CreatePostCubit({PostRepository? postRepository})
      : _postRepository = postRepository ?? sl.postRepository,
        super(CreatePostInitialStates());

  Future<void> createPost(PostsModel posts) async {
    emit(CreatePostLoadingStates());
    try {
      await _postRepository.createPost(posts);
      emit(CreatePostSuccessStates());
    } catch (e) {
      emit(CreatePostErrorStates(friendlyError(e)));
    }
  }
}
