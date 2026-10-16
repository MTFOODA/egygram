import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../models/comment_model.dart';

/// Supabase implementation of [CommentRepository] over the `comments` table.
class CommentRepositoryImpl implements CommentRepository {
  final SupabaseClient _client;

  CommentRepositoryImpl(this._client);

  SupabaseQueryBuilder get _table => _client.from(DbTables.comments);

  @override
  Stream<List<CommentsModel>> watchComments(String postId) {
    return _client
        .from(DbTables.comments)
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => CommentsModel.fromMap(r)).toList());
  }

  @override
  Future<void> addComment(CommentsModel comment) async {
    try {
      final data = comment.toMap()..remove('id');
      final userId = _client.auth.currentUser?.id;
      if (userId != null) data['user_id'] = userId;
      await _table.insert(data);
    } catch (e) {
      throw ServerException('Failed to add comment: $e');
    }
  }
}
