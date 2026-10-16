/// Domain model for a saved post, mapped to the `saves` table.
class SavesModel {
  final String? id;
  final String? userId;
  String userName;
  String postId;
  bool saved;

  SavesModel({
    this.id,
    this.userId,
    required this.userName,
    required this.postId,
    this.saved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'user_name': userName,
      'post_id': postId,
      'saved': saved,
    };
  }

  factory SavesModel.fromMap(Map<String, dynamic> map) {
    return SavesModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      userName: (map['user_name'] ?? map['userName'] ?? '') as String,
      postId: (map['post_id'] ?? map['postId'] ?? '') as String,
      saved: (map['saved'] ?? false) as bool,
    );
  }
}
