import '../../models/comment_model.dart';

/// Comments contract.
abstract class CommentRepository {
  /// Real-time stream of comments for a given post/reel/story id.
  Stream<List<CommentsModel>> watchComments(String postId);

  Future<void> addComment(CommentsModel comment);
}
