import '../core/utils/date_parser.dart';

/// Domain model for a direct message, mapped to the `messages` table.
class MessagesModel {
  final String? id;
  final String? senderId;
  final String? receiverId;
  final String sender;
  final String receiver;
  final String text;
  final String? mediaUrl;
  final DateTime timestamp;

  MessagesModel({
    this.id,
    this.senderId,
    this.receiverId,
    required this.sender,
    required this.receiver,
    required this.text,
    this.mediaUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      'sender_name': sender,
      'receiver_name': receiver,
      'text': text,
      'media_url': mediaUrl,
      'created_at': timestamp.toIso8601String(),
    };
  }

  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      id: map['id'] as String?,
      senderId: map['sender_id'] as String?,
      receiverId: map['receiver_id'] as String?,
      sender: (map['sender_name'] ?? map['sender'] ?? '') as String,
      receiver: (map['receiver_name'] ?? map['receiver'] ?? '') as String,
      text: (map['text'] ?? '') as String,
      mediaUrl: map['media_url'] as String?,
      timestamp: parseDate(map['created_at'] ?? map['timestamp']),
    );
  }
}
