import '../../models/message_model.dart';

/// Direct-message contract backed by the `messages` table + Realtime.
abstract class MessageRepository {
  /// Real-time stream of the conversation between two user names.
  Stream<List<MessagesModel>> watchMessages({
    required String currentUser,
    required String selectedUser,
  });

  /// Persists a new message.
  Future<void> sendMessage({
    required String sender,
    required String receiver,
    required String text,
    String? mediaUrl,
  });
}
