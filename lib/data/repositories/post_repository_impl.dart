import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/post_repository.dart';
import '../../models/post_model.dart';

/// Supabase implementation of [PostRepository] over the `posts` table.
class PostRepositoryImpl implements PostRepository {
  final SupabaseClient _client;

  PostRepositoryImpl(this._client);

  SupabaseQueryBuilder get _table => _client.from(DbTables.posts);

  @override
  Stream<List<PostsModel>> watchPosts() {
    return _client
        .from(DbTables.posts)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => PostsModel.fromMap(r)).toList());
  }

  @override
  Future<void> createPost(PostsModel post) async {
    try {
      final data = post.toMap();
      final userId = _client.auth.currentUser?.id;
      if (userId != null) data['user_id'] = userId;
      await _table.upsert(data);
    } catch (e) {
      throw ServerException('Failed to create post: $e');
    }
  }

  @override
  Future<PostsModel?> getPost(String postId) async {
    try {
      final row = await _table.select().eq('id', postId).maybeSingle();
      return row == null ? null : PostsModel.fromMap(row);
    } catch (e) {
      throw ServerException('Failed to load post: $e');
    }
  }

  @override
  Future<void> updatePost(String postId, PostsModel updatedPost) async {
    try {
      final data = updatedPost.toMap()..remove('id');
      await _table.update(data).eq('id', postId);
    } catch (e) {
      throw ServerException('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _table.delete().eq('id', postId);
    } catch (e) {
      throw ServerException('Failed to delete post: $e');
    }
  }

  @override
  Future<void> adjustCounter({
    required String postId,
    required String column,
    required int delta,
  }) async {
    try {
      await _client.rpc('adjust_content_counter', params: {
        'p_table': DbTables.posts,
        'p_id': postId,
        'p_column': column,
        'p_delta': delta,
      });
    } catch (e) {
      throw ServerException('Failed to adjust counter: $e');
    }
  }
}
