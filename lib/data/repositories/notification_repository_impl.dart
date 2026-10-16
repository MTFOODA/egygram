import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../models/notification_model.dart';

/// Supabase implementation of [NotificationRepository] over `notifications`.
class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  SupabaseQueryBuilder get _table => _client.from(DbTables.notifications);

  @override
  Stream<List<NotificationModel>> watchNotifications(String userName) {
    return _client
        .from(DbTables.notifications)
        .stream(primaryKey: ['id'])
        .eq('user_name', userName)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => NotificationModel.fromMap(r)).toList());
  }

  @override
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _table.insert(notification.toMap()..remove('id'));
    } catch (e) {
      throw ServerException('Failed to create notification: $e');
    }
  }
}
