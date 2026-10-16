import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/user_repository.dart';
import '../../models/user_model.dart';

/// Supabase implementation of [UserRepository] over the `profiles` table.
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _client;

  UserRepositoryImpl(this._client);

  SupabaseQueryBuilder get _table => _client.from(DbTables.profiles);

  @override
  Stream<List<UsersModel>> watchUsers() {
    return _client
        .from(DbTables.profiles)
        .stream(primaryKey: ['id'])
        .order('user_name')
        .map((rows) => rows.map((r) => UsersModel.fromMap(r)).toList());
  }

  @override
  Future<UsersModel?> getUserByName(String userName) async {
    try {
      final row = await _table.select().eq('user_name', userName).maybeSingle();
      return row == null ? null : UsersModel.fromMap(row);
    } catch (e) {
      throw ServerException('Failed to load profile: $e');
    }
  }

  @override
  Future<void> createUser(UsersModel user) async {
    try {
      final data = user.toMap();
      final userId = _client.auth.currentUser?.id;
      if (userId != null) data['id'] = userId;
      await _table.upsert(data);
    } catch (e) {
      throw ServerException('Failed to create profile: $e');
    }
  }

  @override
  Future<void> updateUser(String userName, UsersModel updatedUser) async {
    try {
      final data = updatedUser.toMap()..remove('id');
      await _table.update(data).eq('user_name', userName);
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }
}
