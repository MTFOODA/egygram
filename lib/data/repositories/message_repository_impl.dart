import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/message_repository.dart';
import '../../models/message_model.dart';

/// Supabase implementation of [MessageRepository] over the `messages` table,
/// using Realtime for live conversation updates.
class MessageRepositoryImpl implements MessageRepository {
  final SupabaseClient _client;

  MessageRepositoryImpl(this._client);

  SupabaseQueryBuilder get _table => _client.from(DbTables.messages);

  @override
  Stream<List<MessagesModel>> watchMessages({
    required String currentUser,
    required String selectedUser,
  }) {
    // Supabase Realtime stream filters don't support OR across column pairs,
    // so the conversation is matched client-side on each emission.
    return _client
        .from(DbTables.messages)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((rows) => rows
            .where((r) =>
                (r['sender_name'] == currentUser &&
                    r['receiver_name'] == selectedUser) ||
                (r['sender_name'] == selectedUser &&
                    r['receiver_name'] == currentUser))
            .map((r) => MessagesModel.fromMap(r))
            .toList());
  }

  @override
  Future<void> sendMessage({
    required String sender,
    required String receiver,
    required String text,
    String? mediaUrl,
  }) async {
    try {
      final data = <String, dynamic>{
        'sender_name': sender,
        'receiver_name': receiver,
        'text': text,
        'media_url': mediaUrl,
      };
      final uid = _client.auth.currentUser?.id;
      if (uid != null) data['sender_id'] = uid;
      await _table.insert(data);
    } catch (e) {
      throw ServerException('Failed to send message: $e');
    }
  }
}
