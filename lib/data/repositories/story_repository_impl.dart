import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/story_repository.dart';
import '../../models/story_model.dart';

/// Supabase implementation of [StoryRepository] over the `stories` table.
class StoryRepositoryImpl implements StoryRepository {
  final SupabaseClient _client;

  StoryRepositoryImpl(this._client);

  SupabaseQueryBuilder get _table => _client.from(DbTables.stories);

  @override
  Stream<List<StoriesModel>> watchStories() {
    return _client
        .from(DbTables.stories)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => StoriesModel.fromMap(r)).toList());
  }

  @override
  Future<void> createStory(StoriesModel story) async {
    try {
      final data = story.toMap();
      final userId = _client.auth.currentUser?.id;
      if (userId != null) data['user_id'] = userId;
      await _table.upsert(data);
    } catch (e) {
      throw ServerException('Failed to create story: $e');
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    try {
      await _table.delete().eq('id', storyId);
    } catch (e) {
      throw ServerException('Failed to delete story: $e');
    }
  }

  @override
  Future<int> deleteStoriesOlderThan(Duration maxAge) async {
    try {
      final cutoff = DateTime.now().toUtc().subtract(maxAge).toIso8601String();
      final rows = await _table.delete().lt('created_at', cutoff).select();
      return (rows as List).length;
    } catch (e) {
      throw ServerException('Failed to prune stories: $e');
    }
  }
}
