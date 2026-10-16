import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/reel_repository.dart';
import '../../models/reel_model.dart';

/// Supabase implementation of [ReelRepository] over the `reels` table.
class ReelRepositoryImpl implements ReelRepository {
  final SupabaseClient _client;

  ReelRepositoryImpl(this._client);

  SupabaseQueryBuilder get _table => _client.from(DbTables.reels);

  @override
  Stream<List<ReelsModel>> watchReels() {
    return _client
        .from(DbTables.reels)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => ReelsModel.fromMap(r)).toList());
  }

  @override
  Future<void> createReel(ReelsModel reel) async {
    try {
      final data = reel.toMap();
      final userId = _client.auth.currentUser?.id;
      if (userId != null) data['user_id'] = userId;
      await _table.upsert(data);
    } catch (e) {
      throw ServerException('Failed to create reel: $e');
    }
  }

  @override
  Future<ReelsModel?> getReel(String reelId) async {
    try {
      final row = await _table.select().eq('id', reelId).maybeSingle();
      return row == null ? null : ReelsModel.fromMap(row);
    } catch (e) {
      throw ServerException('Failed to load reel: $e');
    }
  }

  @override
  Future<void> updateReel(String reelId, ReelsModel updatedReel) async {
    try {
      final data = updatedReel.toMap()..remove('id');
      await _table.update(data).eq('id', reelId);
    } catch (e) {
      throw ServerException('Failed to update reel: $e');
    }
  }

  @override
  Future<void> deleteReel(String reelId) async {
    try {
      await _table.delete().eq('id', reelId);
    } catch (e) {
      throw ServerException('Failed to delete reel: $e');
    }
  }
}
