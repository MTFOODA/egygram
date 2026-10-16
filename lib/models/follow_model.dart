/// Domain model for a follow relationship, mapped to the `follows` table.
class FollowsModel {
  final String? id;
  final String? userId;
  String userName;
  String userFollowed;
  bool followed;

  FollowsModel({
    this.id,
    this.userId,
    required this.userName,
    required this.userFollowed,
    this.followed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'user_name': userName,
      'user_followed': userFollowed,
      'followed': followed,
    };
  }

  factory FollowsModel.fromMap(Map<String, dynamic> map) {
    return FollowsModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      userName: (map['user_name'] ?? map['userName'] ?? '') as String,
      userFollowed:
          (map['user_followed'] ?? map['userFollowed'] ?? '') as String,
      followed: (map['followed'] ?? false) as bool,
    );
  }
}
