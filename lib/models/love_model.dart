/// Domain model for a "love" (like) on a post/reel, mapped to `loves`.
class LovesModel {
  final String? id;
  final String? userId;
  String userName;
  String postId;
  bool loved;

  LovesModel({
    this.id,
    this.userId,
    required this.userName,
    required this.postId,
    this.loved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'user_name': userName,
      'post_id': postId,
      'loved': loved,
    };
  }

  factory LovesModel.fromMap(Map<String, dynamic> map) {
    return LovesModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      userName: (map['user_name'] ?? map['userName'] ?? '') as String,
      postId: (map['post_id'] ?? map['postId'] ?? '') as String,
      loved: (map['loved'] ?? false) as bool,
    );
  }
}
