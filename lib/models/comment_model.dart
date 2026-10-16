import '../core/utils/date_parser.dart';

/// Domain model for a comment, mapped to the `comments` table.
class CommentsModel {
  final String? id;
  String userName;
  final String? profileImage;
  String postId;
  String content;
  final DateTime time;

  CommentsModel({
    this.id,
    required this.userName,
    this.profileImage,
    required this.postId,
    required this.content,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_name': userName,
      "profile_image": profileImage,
      'post_id': postId,
      'content': content,
      "created_at": time.toIso8601String(),
    };
  }

  factory CommentsModel.fromMap(Map<String, dynamic> map) {
    return CommentsModel(
      id: map['id'] as String?,
      userName: (map['user_name'] ?? map['userName'] ?? '') as String,
      profileImage:
          (map["profile_image"] ?? map["profileImage"] ?? "") as String?,
      postId: (map['post_id'] ?? map['postId'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      time: parseDate(map["created_at"] ?? map["createdAt"]),
    );
  }
}
