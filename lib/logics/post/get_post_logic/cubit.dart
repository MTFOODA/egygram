import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetPostCubit extends Cubit<GetPostsState> {
  final PostRepository _postRepository;
  StreamSubscription<List<PostsModel>>? _subscription;

  GetPostCubit({PostRepository? postRepository})
      : _postRepository = postRepository ?? sl.postRepository,
        super(GetPostInitialState());

  Stream<List<PostsModel>> getPost() => _postRepository.watchPosts();

  void subscribeToPosts() {
    emit(GetPostLoadingState());
    _subscription?.cancel();
    _subscription = getPost().listen(
      (posts) => emit(GetPostSuccessState(posts)),
      onError: (error) => emit(GetPostErrorState(friendlyError(error))),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
