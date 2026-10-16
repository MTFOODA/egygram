import '../core/utils/date_parser.dart';

/// In-app notification, mapped to the `notifications` table.
///
/// Push delivery (FCM/APNs) is out of scope for the client build; these rows
/// power the in-app notifications UI. See the project guide.
class NotificationModel {
  final String? id;
  final String userName;
  final String actorName;
  final String type; // e.g. 'love', 'comment', 'follow'
  final String body;
  final String? postId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    required this.userName,
    required this.actorName,
    required this.type,
    required this.body,
    this.postId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_name': userName,
      'actor_name': actorName,
      'type': type,
      'body': body,
      'post_id': postId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String?,
      userName: (map['user_name'] ?? '') as String,
      actorName: (map['actor_name'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      body: (map['body'] ?? '') as String,
      postId: map['post_id'] as String?,
      isRead: (map['is_read'] ?? false) as bool,
      createdAt: parseDate(map['created_at']),
    );
  }
}
