import 'dart:async';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/comment_repository.dart';
import '../../../models/comment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class GetCommentCubit extends Cubit<GetCommentsState> {
  final CommentRepository _commentRepository;
  StreamSubscription<List<CommentsModel>>? _subscription;

  GetCommentCubit({CommentRepository? commentRepository})
      : _commentRepository = commentRepository ?? sl.commentRepository,
        super(GetCommentInitialState());

  void getComments(String postId) {
    emit(GetCommentLoadingState());
    _subscription?.cancel();
    _subscription = _commentRepository.watchComments(postId).listen(
          (comments) => emit(GetCommentSuccessState(comments)),
          onError: (error) => emit(GetCommentErrorState(friendlyError(error))),
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
