import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/social_repository.dart';
import '../../models/follow_model.dart';
import '../../models/love_model.dart';
import '../../models/save_model.dart';

/// Supabase implementation of [SocialRepository].
///
/// Toggles insert/delete a row in the respective table and then call SECURITY
/// DEFINER RPCs (`adjust_content_counter`, `adjust_profile_counter`) to keep
/// denormalised counters consistent without violating RLS.
class SocialRepositoryImpl implements SocialRepository {
  final SupabaseClient _client;

  SocialRepositoryImpl(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  SupabaseQueryBuilder get _follows => _client.from(DbTables.follows);
  SupabaseQueryBuilder get _loves => _client.from(DbTables.loves);
  SupabaseQueryBuilder get _saves => _client.from(DbTables.saves);

  // ---------------------------------------------------------------------------
  // Follows
  // ---------------------------------------------------------------------------
  @override
  Future<void> toggleFollow(FollowsModel follow) async {
    try {
      final existing = await _follows
          .select('id')
          .eq('user_name', follow.userName)
          .eq('user_followed', follow.userFollowed)
          .maybeSingle();

      final willFollow = existing == null;

      if (existing == null) {
        final data = follow.toMap();
        final uid = _userId;
        if (uid != null) data['user_id'] = uid;
        await _follows.insert(data);
      } else {
        await _follows.delete().eq('id', existing['id'] as String);
      }

      // Adjust counters on both profiles atomically (server-side).
      await _client.rpc('adjust_profile_counter', params: {
        'p_user_name': follow.userFollowed,
        'p_column': 'number_of_followers',
        'p_delta': willFollow ? 1 : -1,
      });
      await _client.rpc('adjust_profile_counter', params: {
        'p_user_name': follow.userName,
        'p_column': 'number_of_following',
        'p_delta': willFollow ? 1 : -1,
      });
    } catch (e) {
      throw ServerException('Failed to toggle follow: $e');
    }
  }

  @override
  Future<List<FollowsModel>> getFollows(String userName) async {
    try {
      final rows = await _follows.select().eq('user_name', userName);
      return rows.map((r) => FollowsModel.fromMap(r)).toList();
    } catch (e) {
      throw ServerException('Failed to load follows: $e');
    }
  }

  @override
  Future<bool> getFollowStatus(String userFollowed, String userName) async {
    try {
      final row = await _follows
          .select('id')
          .eq('user_followed', userFollowed)
          .eq('user_name', userName)
          .maybeSingle();
      return row != null;
    } catch (e) {
      throw ServerException('Failed to load follow status: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Loves
  // ---------------------------------------------------------------------------
  @override
  Future<void> toggleLove(LovesModel love) async {
    try {
      final existing = await _loves
          .select('id')
          .eq('post_id', love.postId)
          .eq('user_name', love.userName)
          .maybeSingle();

      final willLove = existing == null;

      if (existing == null) {
        final data = love.toMap();
        final uid = _userId;
        if (uid != null) data['user_id'] = uid;
        await _loves.insert(data);
      } else {
        await _loves.delete().eq('id', existing['id'] as String);
      }

      await _client.rpc('adjust_content_counter', params: {
        'p_table': DbTables.posts,
        'p_id': love.postId,
        'p_column': 'loves',
        'p_delta': willLove ? 1 : -1,
      });
    } catch (e) {
      throw ServerException('Failed to toggle love: $e');
    }
  }

  @override
  Future<List<LovesModel>> getLoves(String userName) async {
    try {
      final rows = await _loves.select().eq('user_name', userName);
      return rows.map((r) => LovesModel.fromMap(r)).toList();
    } catch (e) {
      throw ServerException('Failed to load loves: $e');
    }
  }

  @override
  Future<bool> getLoveStatus(String postId, String userName) async {
    try {
      final row = await _loves
          .select('id')
          .eq('post_id', postId)
          .eq('user_name', userName)
          .maybeSingle();
      return row != null;
    } catch (e) {
      throw ServerException('Failed to load love status: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Saves
  // ---------------------------------------------------------------------------
  @override
  Future<void> toggleSave(SavesModel save) async {
    try {
      final existing = await _saves
          .select('id')
          .eq('post_id', save.postId)
          .eq('user_name', save.userName)
          .maybeSingle();

      if (existing == null) {
        final data = save.toMap();
        final uid = _userId;
        if (uid != null) data['user_id'] = uid;
        await _saves.insert(data);
      } else {
        await _saves.delete().eq('id', existing['id'] as String);
      }
    } catch (e) {
      throw ServerException('Failed to toggle save: $e');
    }
  }

  @override
  Future<List<SavesModel>> getSaves(String userName) async {
    try {
      final rows = await _saves.select().eq('user_name', userName);
      return rows.map((r) => SavesModel.fromMap(r)).toList();
    } catch (e) {
      throw ServerException('Failed to load saves: $e');
    }
  }

  @override
  Future<bool> getSaveStatus(String postId, String userName) async {
    try {
      final row = await _saves
          .select('id')
          .eq('post_id', postId)
          .eq('user_name', userName)
          .maybeSingle();
      return row != null;
    } catch (e) {
      throw ServerException('Failed to load save status: $e');
    }
  }
}
