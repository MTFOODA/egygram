import '../../models/post_model.dart';

/// Posts contract.
abstract class PostRepository {
  Stream<List<PostsModel>> watchPosts();

  Future<void> createPost(PostsModel post);

  Future<PostsModel?> getPost(String postId);

  Future<void> updatePost(String postId, PostsModel updatedPost);

  Future<void> deletePost(String postId);

  /// Atomically increments/decrements a numeric counter column on a post.
  /// Used for shares (loves/comments are handled by their own repositories).
  Future<void> adjustCounter({
    required String postId,
    required String column,
    required int delta,
  });
}
