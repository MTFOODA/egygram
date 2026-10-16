import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../domain/repositories/comment_repository.dart';
import '../../../models/comment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class CreateCommentCubit extends Cubit<CreateCommentStates> {
  final CommentRepository _commentRepository;

  CreateCommentCubit({CommentRepository? commentRepository})
      : _commentRepository = commentRepository ?? sl.commentRepository,
        super(CreateCommentInitialStates());

  Future createComment(CommentsModel comments) async {
    emit(CreateCommentLoadingStates());
    try {
      await _commentRepository.addComment(comments);
      emit(CreateCommentSuccessStates());
    } catch (e) {
      emit(CreateCommentErrorStates(friendlyError(e)));
    }
  }
}
